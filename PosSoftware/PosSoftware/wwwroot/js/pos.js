let cart = [];
let taxRate = 0.0;
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
        }, 250);
    });

    document.getElementById('paidAmountInput')?.addEventListener('input', calculateTotals);

    document.getElementById('taxRateInput')?.addEventListener('input', function () {
        taxRate = parseFloat(this.value) || 0;
        calculateTotals();
    });

    document.getElementById('discountPercentInput')?.addEventListener('input', function () {
        discountPercent = parseFloat(this.value) || 0;
        calculateTotals();
    });
});

function getActiveCategoryId() {
    const activePill = document.querySelector('.category-pill.active');
    return activePill ? activePill.dataset.categoryId : '0';
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
        const name = (card.dataset.name || '').toLowerCase();
        const barcode = (card.dataset.barcode || '').toLowerCase();
        const sku = (card.dataset.sku || '').toLowerCase();
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
        gain.gain.setValueAtTime(0.08, audioCtx.currentTime);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.08);
    } catch (e) {
        // audio context not allowed before user interaction
    }
}

// -------------------------------------------------------------
// Cart Management & Editable Qty / Price (Requirement 1)
// -------------------------------------------------------------

function addToCart(product) {
    const prodId = product.id || product.Id;
    const existing = cart.find(x => x.productId === prodId);

    if (existing) {
        if (existing.quantity >= existing.currentStock) {
            Swal.fire({
                icon: 'warning',
                title: 'Insufficient Stock',
                text: `Available stock for '${existing.name}' is only ${existing.currentStock}.`,
                timer: 2000,
                showConfirmButton: false
            });
            return;
        }
        existing.quantity += 1;
    } else {
        const stock = product.currentStock ?? product.CurrentStock ?? 0;
        if (stock <= 0) {
            Swal.fire({
                icon: 'error',
                title: 'Out of Stock',
                text: `'${product.name || product.Name}' is currently out of stock!`,
                timer: 2000,
                showConfirmButton: false
            });
            return;
        }
        cart.push({
            productId: prodId,
            name: product.name || product.Name,
            barcode: product.barcode || product.Barcode || '',
            sku: product.sku || product.SKU || '',
            unitPrice: parseFloat(product.sellingPrice ?? product.SellingPrice ?? 0),
            costPrice: parseFloat(product.costPrice ?? product.CostPrice ?? 0),
            currentStock: stock,
            unitName: product.unitName || 'pcs',
            quantity: 1,
            discountAmount: 0
        });
    }

    renderCart();
    updateLeftCardIndicators();
}

function stepCartQty(index, delta) {
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
            title: 'Stock Limit',
            text: `Available stock for '${item.name}' is ${item.currentStock}.`,
            timer: 1500,
            showConfirmButton: false
        });
        return;
    }

    item.quantity = newQty;
    const qtyInput = document.getElementById(`cartQtyInput_${index}`);
    if (qtyInput) qtyInput.value = newQty;

    const rowTotal = (item.unitPrice * item.quantity) - item.discountAmount;
    const totalEl = document.getElementById(`cartRowTotal_${index}`);
    if (totalEl) totalEl.innerText = '৳ ' + rowTotal.toFixed(2);

    calculateTotals();
    updateLeftCardIndicators();
}

function onCartItemQtyInput(index, val) {
    const item = cart[index];
    if (!item) return;

    let qty = parseInt(val);
    if (isNaN(qty) || qty < 1) {
        qty = 1;
    }
    if (qty > item.currentStock) {
        qty = item.currentStock;
        const input = document.getElementById(`cartQtyInput_${index}`);
        if (input) input.value = qty;
        Swal.fire({
            icon: 'warning',
            title: 'Stock Limit',
            text: `Available stock for '${item.name}' is ${item.currentStock}.`,
            timer: 1500,
            showConfirmButton: false
        });
    }

    item.quantity = qty;
    const rowTotal = (item.unitPrice * item.quantity) - item.discountAmount;
    const totalEl = document.getElementById(`cartRowTotal_${index}`);
    if (totalEl) totalEl.innerText = '৳ ' + rowTotal.toFixed(2);

    calculateTotals();
    updateLeftCardIndicators();
}

function onCartItemPriceInput(index, val) {
    const item = cart[index];
    if (!item) return;

    let price = parseFloat(val);
    if (isNaN(price) || price < 0) {
        price = 0;
    }

    item.unitPrice = price;
    const rowTotal = (item.unitPrice * item.quantity) - item.discountAmount;
    const totalEl = document.getElementById(`cartRowTotal_${index}`);
    if (totalEl) totalEl.innerText = '৳ ' + rowTotal.toFixed(2);

    calculateTotals();
    updateLeftCardIndicators();
}

function removeFromCart(index) {
    cart.splice(index, 1);
    renderCart();
    updateLeftCardIndicators();
}

function clearCart() {
    if (cart.length === 0) return;
    cart = [];
    renderCart();
    updateLeftCardIndicators();
}

function renderCart() {
    const tbody = document.getElementById('cartTableBody');
    const badge = document.getElementById('cartItemCountBadge');
    if (badge) badge.innerText = cart.reduce((sum, item) => sum + item.quantity, 0);

    if (!tbody) return;

    if (cart.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="5" class="text-center text-muted py-5">
                    <i class="bi bi-cart-x fs-1 d-block mb-2"></i>
                    Cart is empty. Scan barcode or click products.
                </td>
            </tr>`;
        calculateTotals();
        return;
    }

    let html = '';
    cart.forEach((item, index) => {
        const rowTotal = (item.unitPrice * item.quantity) - item.discountAmount;
        html += `
            <tr id="cartRow_${index}">
                <td>
                    <div class="fw-semibold text-dark text-truncate" style="max-width: 120px;" title="${item.name}">${item.name}</div>
                    <small class="text-muted font-monospace" style="font-size: 0.72rem;">${item.sku || item.barcode || ''}</small>
                </td>
                <td class="text-center">
                    <div class="input-group input-group-sm d-inline-flex" style="width: 90px;">
                        <button class="btn btn-outline-secondary px-1 py-0" type="button" onclick="stepCartQty(${index}, -1)">-</button>
                        <input type="number" class="form-control text-center p-0 fw-bold" id="cartQtyInput_${index}" min="1" max="${item.currentStock}" value="${item.quantity}" oninput="onCartItemQtyInput(${index}, this.value)" />
                        <button class="btn btn-outline-secondary px-1 py-0" type="button" onclick="stepCartQty(${index}, 1)">+</button>
                    </div>
                </td>
                <td class="text-end">
                    <input type="number" step="any" min="0" class="form-control form-control-sm text-end p-1 fw-semibold" id="cartPriceInput_${index}" value="${item.unitPrice}" oninput="onCartItemPriceInput(${index}, this.value)" style="width: 85px; display: inline-block;" />
                </td>
                <td class="text-end fw-bold text-dark" id="cartRowTotal_${index}">
                    ৳ ${rowTotal.toFixed(2)}
                </td>
                <td class="text-center">
                    <button class="btn btn-sm btn-link text-danger p-0" onclick="removeFromCart(${index})" title="Remove item">
                        <i class="bi bi-trash"></i>
                    </button>
                </td>
            </tr>
        `;
    });

    tbody.innerHTML = html;
    calculateTotals();
}

// -------------------------------------------------------------
// Left-Side Real-Time Indicators & Summary (Requirement 2)
// -------------------------------------------------------------

function updateLeftCardIndicators() {
    const inCartMap = new Map();
    cart.forEach(item => {
        inCartMap.set(item.productId, item);
    });

    // Update each product card's badge and active border
    document.querySelectorAll('.card-selected-indicator').forEach(badge => {
        const prodId = parseInt(badge.id.replace('cardSelectedBadge_', ''));
        const card = document.getElementById(`posProductCard_${prodId}`);
        const item = inCartMap.get(prodId);

        if (item && item.quantity > 0) {
            badge.classList.remove('d-none');
            const qtyEl = document.getElementById(`cardSelectedQty_${prodId}`);
            const amtEl = document.getElementById(`cardSelectedAmt_${prodId}`);
            if (qtyEl) qtyEl.innerText = item.quantity;
            if (amtEl) amtEl.innerText = (item.quantity * item.unitPrice).toFixed(2);
            card?.classList.add('selected-active');
        } else {
            badge.classList.add('d-none');
            card?.classList.remove('selected-active');
        }
    });

    // Update the Left Selection Summary Bar
    const summaryBar = document.getElementById('leftSelectedSummaryBar');
    if (summaryBar) {
        if (cart.length > 0) {
            summaryBar.classList.remove('d-none');
            summaryBar.classList.add('d-flex');
            const totalQty = cart.reduce((s, i) => s + i.quantity, 0);
            const totalAmt = cart.reduce((s, i) => s + (i.quantity * i.unitPrice), 0);
            document.getElementById('leftSelItemCount').innerText = `${cart.length} ${cart.length === 1 ? 'item' : 'items'}`;
            document.getElementById('leftSelTotalQty').innerText = `${totalQty} pcs`;
            document.getElementById('leftSelTotalAmt').innerText = `৳ ${totalAmt.toFixed(2)}`;
        } else {
            summaryBar.classList.add('d-none');
            summaryBar.classList.remove('d-flex');
        }
    }
}

// -------------------------------------------------------------
// Totals & Checkout Calculations
// -------------------------------------------------------------

function selectPaymentMethod(method, element) {
    paymentMethod = method;
    document.querySelectorAll('.payment-btn').forEach(btn => btn.classList.remove('active', 'btn-primary'));
    element.classList.add('active', 'btn-primary');
    element.classList.remove('btn-outline-primary');
}

function setQuickTender(amount) {
    const paidInput = document.getElementById('paidAmountInput');
    if (paidInput) {
        paidInput.value = amount;
        calculateTotals();
    }
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

    document.getElementById('lblSubtotal')?.replaceChildren(document.createTextNode('৳ ' + subtotal.toFixed(2)));
    document.getElementById('lblTax')?.replaceChildren(document.createTextNode('৳ ' + taxAmount.toFixed(2)));
    document.getElementById('lblDiscount')?.replaceChildren(document.createTextNode('৳ ' + discAmount.toFixed(2)));
    document.getElementById('lblGrandTotal')?.replaceChildren(document.createTextNode('৳ ' + grandTotal.toFixed(2)));
    document.getElementById('lblChangeDue')?.replaceChildren(document.createTextNode('৳ ' + changeAmount.toFixed(2)));

    return { subtotal, discAmount, taxAmount, grandTotal, paidAmount, changeAmount };
}

// -------------------------------------------------------------
// Checkout & Invoice Report In-Page (Requirements 3 & 4)
// -------------------------------------------------------------

function processCheckout() {
    if (cart.length === 0) {
        Swal.fire('Empty Cart', 'Please select at least one product before checkout.', 'warning');
        return;
    }

    const { subtotal, discAmount, taxAmount, grandTotal, paidAmount, changeAmount } = calculateTotals();

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
        PaidAmount: paidAmount > 0 ? paidAmount : grandTotal,
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

    // Show loading state
    Swal.fire({
        title: 'Processing Order...',
        text: 'Saving sale and generating invoice report',
        allowOutsideClick: false,
        didOpen: () => {
            Swal.showLoading();
        }
    });

    fetch('/Pos/ProcessCheckout', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    })
    .then(r => r.json())
    .then(data => {
        Swal.close();
        if (data.success) {
            // Requirement 4: Show Invoice Report directly on this page via Modal/Iframe
            document.getElementById('modalInvoiceNo').innerText = data.invoiceNumber;
            const invoiceFrame = document.getElementById('posInvoiceFrame');
            if (invoiceFrame) {
                invoiceFrame.src = `/Sales/GetReport/${data.saleId}`;
            }

            const modalEl = document.getElementById('posInvoiceModal');
            if (modalEl) {
                const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
                modal.show();
            }
        } else {
            Swal.fire('Error', data.message || 'Checkout failed.', 'error');
        }
    })
    .catch(err => {
        Swal.close();
        console.error(err);
        Swal.fire('Error', 'Network or server communication error.', 'error');
    });
}

function printPosInvoice() {
    const iframe = document.getElementById('posInvoiceFrame');
    if (iframe && iframe.contentWindow) {
        iframe.contentWindow.focus();
        iframe.contentWindow.print();
    }
}

function resetPosForNextOrder() {
    cart = [];
    renderCart();
    updateLeftCardIndicators();
    const paidInput = document.getElementById('paidAmountInput');
    if (paidInput) paidInput.value = '';
    calculateTotals();
    document.getElementById('posBarcodeInput')?.focus();
}
