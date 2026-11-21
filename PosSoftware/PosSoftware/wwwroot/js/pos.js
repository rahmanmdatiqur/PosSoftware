let cart = [];
let taxRate = 5.0;
let discountPercent = 0.0;
let paymentMethod = 'Cash';

document.addEventListener('DOMContentLoaded', function () {
    const barcodeInput = document.getElementById('posBarcodeInput');
    barcodeInput?.focus();

    barcodeInput?.addEventListener('keypress', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            const barcode = this.value.trim();
            if (barcode) {
                lookupBarcode(barcode);
                this.value = '';
            }
        }
    });

    const searchInput = document.getElementById('posSearchInput');
    let debounceTimer;
    searchInput?.addEventListener('input', function () {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => {
            filterProducts(this.value.trim(), getActiveCategoryId());
        }, 300);
    });

    document.getElementById('paidAmountInput')?.addEventListener('input', calculateTotals);
    document.getElementById('taxRateInput')?.addEventListener('input', function() {
        taxRate = parseFloat(this.value) || 0;
        calculateTotals();
    });
    document.getElementById('discountPercentInput')?.addEventListener('input', function() {
        discountPercent = parseFloat(this.value) || 0;
        calculateTotals();
    });
});

function getActiveCategoryId() {
    const activePill = document.querySelector('.category-pill.active');
    return activePill ? activePill.dataset.categoryId : '';
}

function selectCategory(catId, element) {
    document.querySelectorAll('.category-pill').forEach(el => el.classList.remove('active'));
    element.classList.add('active');
    const search = document.getElementById('posSearchInput')?.value.trim() || '';
    filterProducts(search, catId);
}

function filterProducts(query, categoryId) {
    const cards = document.querySelectorAll('.pos-product-item');
    cards.forEach(card => {
        const name = card.dataset.name.toLowerCase();
        const barcode = card.dataset.barcode.toLowerCase();
        const sku = card.dataset.sku.toLowerCase();
        const cardCatId = card.dataset.categoryId;

        const matchesQuery = !query || name.includes(query.toLowerCase()) || barcode.includes(query.toLowerCase()) || sku.includes(query.toLowerCase());
        const matchesCategory = !categoryId || categoryId === '0' || cardCatId === categoryId;

        if (matchesQuery && matchesCategory) {
            card.style.display = 'block';
        } else {
            card.style.display = 'none';
        }
    });
}

function lookupBarcode(barcode) {
    fetch(`/Pos/GetProductByBarcode?barcode=${encodeURIComponent(barcode)}`)
        .then(res => res.json())
        .then(data => {
            if (data.success && data.product) {
                addToCart(data.product);
                playBeep();
            } else {
                Swal.fire({
                    icon: 'warning',
                    title: 'Not Found',
                    text: `No active product found for barcode: ${barcode}`,
                    timer: 2000,
                    showConfirmButton: false
                });
            }
        })
        .catch(err => {
            console.error(err);
        });
}

function playBeep() {
    try {
        const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(880, audioCtx.currentTime);
        gain.gain.setValueAtTime(0.1, audioCtx.currentTime);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.1);
    } catch (e) {
        // audio context not allowed before user interaction
    }
}

function addToCart(product) {
    const existing = cart.find(x => x.productId === product.id || x.productId === product.Id);
    if (existing) {
        if (existing.quantity >= product.currentStock) {
            Swal.fire({
                icon: 'warning',
                title: 'Insufficient Stock',
                text: `Available stock for '${product.name || product.Name}' is only ${product.currentStock}.`,
                timer: 2000,
                showConfirmButton: false
            });
            return;
        }
        existing.quantity += 1;
    } else {
        if (product.currentStock <= 0) {
            Swal.fire({
                icon: 'error',
                title: 'Out of Stock',
                text: `'${product.name || product.Name}' is out of stock!`,
                timer: 2000,
                showConfirmButton: false
            });
            return;
        }
        cart.push({
            productId: product.id || product.Id,
            name: product.name || product.Name,
            barcode: product.barcode || product.Barcode,
            unitPrice: product.sellingPrice || product.SellingPrice,
            costPrice: product.costPrice || product.CostPrice,
            currentStock: product.currentStock || product.CurrentStock,
            quantity: 1,
            discountAmount: 0
        });
    }

    renderCart();
}

function updateQuantity(index, delta) {
    const item = cart[index];
    if (!item) return;

    const newQty = item.quantity + delta;
    if (newQty <= 0) {
        removeFromCart(index);
        return;
    }
    if (newQty > item.currentStock) {
        Swal.fire({
            icon: 'warning',
            title: 'Max Stock Reached',
            text: `Available stock is only ${item.currentStock}.`,
            timer: 2000,
            showConfirmButton: false
        });
        return;
    }

    item.quantity = newQty;
    renderCart();
}

function removeFromCart(index) {
    cart.splice(index, 1);
    renderCart();
}

function clearCart() {
    if (cart.length === 0) return;
    cart = [];
    renderCart();
}

function selectPaymentMethod(method, element) {
    paymentMethod = method;
    document.querySelectorAll('.payment-btn').forEach(btn => btn.classList.remove('active', 'btn-primary'));
    element.classList.add('active', 'btn-primary');
    element.classList.remove('btn-outline-primary');
}

function setQuickTender(amount) {
    const paidInput = document.getElementById('paidAmountInput');
    if (paidInput) {
        paidInput.value = amount.toFixed(2);
        calculateTotals();
    }
}

function renderCart() {
    const tbody = document.getElementById('cartTableBody');
    const badge = document.getElementById('cartItemCountBadge');
    if (badge) badge.innerText = cart.reduce((sum, item) => sum + item.quantity, 0);

    if (!tbody) return;

    if (cart.length === 0) {
        tbody.innerHTML = `<tr><td colspan="4" class="text-center text-muted py-5"><i class="bi bi-cart-x fs-1 d-block mb-2"></i>Cart is empty. Scan barcode or click products.</td></tr>`;
        calculateTotals();
        return;
    }

    let html = '';
    cart.forEach((item, index) => {
        const rowTotal = (item.unitPrice * item.quantity) - item.discountAmount;
        html += `
            <tr>
                <td class="text-truncate" style="max-width: 140px;">
                    <div class="fw-semibold text-dark text-truncate">${item.name}</div>
                    <small class="text-muted">$${item.unitPrice.toFixed(2)}</small>
                </td>
                <td class="text-center">
                    <div class="input-group input-group-sm d-inline-flex" style="width: 80px;">
                        <button class="btn btn-outline-secondary p-0 px-1" onclick="updateQuantity(${index}, -1)">-</button>
                        <input type="text" class="form-control text-center p-0" value="${item.quantity}" readonly />
                        <button class="btn btn-outline-secondary p-0 px-1" onclick="updateQuantity(${index}, 1)">+</button>
                    </div>
                </td>
                <td class="text-end fw-bold">$${rowTotal.toFixed(2)}</td>
                <td class="text-center">
                    <button class="btn btn-sm btn-link text-danger p-0" onclick="removeFromCart(${index})">
                        <i class="bi bi-trash"></i>
                    </button>
                </td>
            </tr>
        `;
    });

    tbody.innerHTML = html;
    calculateTotals();
}

function calculateTotals() {
    const subtotal = cart.reduce((sum, item) => sum + (item.unitPrice * item.quantity), 0);
    const discAmount = (subtotal * (discountPercent / 100));
    const taxableAmount = Math.max(0, subtotal - discAmount);
    const taxAmount = (taxableAmount * (taxRate / 100));
    const grandTotal = taxableAmount + taxAmount;

    const paidInput = document.getElementById('paidAmountInput');
    const paidAmount = parseFloat(paidInput?.value) || 0;
    const changeAmount = Math.max(0, paidAmount - grandTotal);

    document.getElementById('lblSubtotal')?.replaceChildren(document.createTextNode('$' + subtotal.toFixed(2)));
    document.getElementById('lblTax')?.replaceChildren(document.createTextNode('$' + taxAmount.toFixed(2)));
    document.getElementById('lblDiscount')?.replaceChildren(document.createTextNode('$' + discAmount.toFixed(2)));
    document.getElementById('lblGrandTotal')?.replaceChildren(document.createTextNode('$' + grandTotal.toFixed(2)));
    document.getElementById('lblChangeDue')?.replaceChildren(document.createTextNode('$' + changeAmount.toFixed(2)));

    return { subtotal, discAmount, taxAmount, grandTotal, paidAmount, changeAmount };
}

function processCheckout() {
    if (cart.length === 0) {
        Swal.fire('Empty Cart', 'Please add items before checkout.', 'warning');
        return;
    }

    const { subtotal, discAmount, taxAmount, grandTotal, paidAmount, changeAmount } = calculateTotals();

    if (paymentMethod === 'Cash' && paidAmount < grandTotal) {
        Swal.fire('Insufficient Tender', 'Paid cash amount is less than Grand Total!', 'warning');
        return;
    }

    const customerSelect = document.getElementById('posCustomerSelect');
    const customerId = parseInt(customerSelect?.value) || 1;

    const payload = {
        CustomerId: customerId,
        SubTotal: subtotal,
        TaxRate: taxRate,
        TaxAmount: taxAmount,
        DiscountPercent: discountPercent,
        DiscountAmount: discAmount,
        GrandTotal: grandTotal,
        PaidAmount: paymentMethod === 'Cash' ? paidAmount : grandTotal,
        ChangeAmount: changeAmount,
        PaymentMethod: paymentMethod,
        Items: cart.map(i => ({
            ProductId: i.productId,
            Barcode: i.barcode,
            Name: i.name,
            UnitPrice: i.unitPrice,
            CostPrice: i.costPrice,
            Quantity: i.quantity,
            DiscountAmount: i.discountAmount
        }))
    };

    fetch('/Pos/ProcessCheckout', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            Swal.fire({
                icon: 'success',
                title: 'Payment Successful!',
                text: `Invoice #${data.invoiceNumber} created. Change Due: $${data.changeAmount.toFixed(2)}`,
                showCancelButton: true,
                confirmButtonText: '<i class="bi bi-printer"></i> Print Receipt',
                cancelButtonText: 'New Sale'
            }).then((res) => {
                if (res.isConfirmed) {
                    window.open(`/Pos/PrintReceipt?id=${data.saleId}`, '_blank');
                }
                clearCart();
                document.getElementById('paidAmountInput').value = '';
                calculateTotals();
            });
        } else {
            Swal.fire('Error', data.message || 'Checkout failed.', 'error');
        }
    })
    .catch(err => {
        Swal.fire('Error', 'Network or server communication error.', 'error');
    });
}
