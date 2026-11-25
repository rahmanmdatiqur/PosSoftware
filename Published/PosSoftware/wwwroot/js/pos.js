let cart = [];
let payments = [];
let taxRate = 0.0;
let sdRate = 0.0;
let discountAmount = 0.0;
let discountPercent = 0.0;
let paymentMethod = 'Cash';

// Catalog Pagination & Filter State matching Screenshot 1
let catalogCurrentPage = 1;
let catalogPageSize = 20;

document.addEventListener('DOMContentLoaded', function () {
    const searchInput = document.getElementById('posSearchInput');
    let debounceTimer;
    searchInput?.addEventListener('input', function () {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => {
            catalogCurrentPage = 1;
            applyCatalogFilters();
        }, 200);
    });

    // Initialize Parked Orders Count
    updateParkedOrdersCount();

    // Initial catalog render with pagination
    applyCatalogFilters();

    // Barcode scanner auto-listen anywhere on keypress if not inside input
    document.addEventListener('keypress', function (e) {
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'SELECT' || e.target.tagName === 'TEXTAREA') {
            return;
        }
        if (e.key === 'Enter') {
            // Can be used for hardware barcode scanner buffer
        }
    });
});

// -------------------------------------------------------------
// Catalog Filter & Pagination (Screenshot 1: SHOW 20, Prev, Next)
// -------------------------------------------------------------

function applyCatalogFilters() {
    const query = (document.getElementById('posSearchInput')?.value || '').trim().toLowerCase();
    const categoryId = document.getElementById('posCategorySelect')?.value || '0';
    const allCards = Array.from(document.querySelectorAll('.pos-product-item'));

    // Filter matching cards
    const matchedCards = allCards.filter(card => {
        const name = (card.dataset.name || '').toLowerCase();
        const barcode = (card.dataset.barcode || '').toLowerCase();
        const sku = (card.dataset.sku || '').toLowerCase();
        const cardCatId = card.dataset.categoryId;

        const matchesQuery = !query || name.includes(query) || barcode.includes(query) || sku.includes(query);
        const matchesCategory = !categoryId || categoryId === '0' || cardCatId === categoryId;
        return matchesQuery && matchesCategory;
    });

    const totalMatched = matchedCards.length;
    const totalPages = Math.max(1, Math.ceil(totalMatched / catalogPageSize));
    if (catalogCurrentPage > totalPages) catalogCurrentPage = totalPages;
    if (catalogCurrentPage < 1) catalogCurrentPage = 1;

    const startIndex = (catalogCurrentPage - 1) * catalogPageSize;
    const endIndex = Math.min(startIndex + catalogPageSize, totalMatched);

    // Hide all first
    allCards.forEach(card => card.style.display = 'none');

    // Show only the page slice of matched
    for (let i = startIndex; i < endIndex; i++) {
        matchedCards[i].style.display = 'block';
    }

    // Update pagination footer text
    const infoEl = document.getElementById('posPaginationInfo');
    if (infoEl) {
        if (totalMatched === 0) {
            infoEl.innerText = '0-0 of 0';
        } else {
            infoEl.innerText = `${startIndex + 1}-${endIndex} of ${totalMatched}`;
        }
    }

    // Prev / Next button states
    const btnPrev = document.getElementById('btnPrevPage');
    const btnNext = document.getElementById('btnNextPage');
    if (btnPrev) btnPrev.disabled = (catalogCurrentPage <= 1);
    if (btnNext) btnNext.disabled = (catalogCurrentPage >= totalPages || totalMatched === 0);
}

function prevCatalogPage() {
    if (catalogCurrentPage > 1) {
        catalogCurrentPage--;
        applyCatalogFilters();
        scrollCatalogToTop();
    }
}

function nextCatalogPage() {
    catalogCurrentPage++;
    applyCatalogFilters();
    scrollCatalogToTop();
}

function changePageSize(val) {
    catalogPageSize = parseInt(val) || 20;
    catalogCurrentPage = 1;
    applyCatalogFilters();
}

function changeGridColumns(colsClass) {
    const grid = document.getElementById('posProductGrid');
    if (grid) {
        grid.className = `row ${colsClass} g-3`;
    }
}

function onCategorySelectChange(val) {
    catalogCurrentPage = 1;
    applyCatalogFilters();
}

function scrollCatalogToTop() {
    const scrollPane = document.getElementById('posCatalogScroll');
    if (scrollPane) scrollPane.scrollTop = 0;
}

// -------------------------------------------------------------
// Cart Management & Editable Qty / Price (Screenshot 1)
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
                timer: 1800,
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
                text: `'${product.name || product.Name}' is out of stock!`,
                timer: 1800,
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
    updateCatalogSelectionIndicators();
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
    const totalInput = document.getElementById(`cartPriceInput_${index}`);
    if (totalInput) totalInput.value = rowTotal.toFixed(2);

    calculateTotals();
    updateCatalogSelectionIndicators();
}

function onCartItemQtyInput(index, val) {
    const item = cart[index];
    if (!item) return;

    let qty = parseInt(val);
    if (isNaN(qty) || qty < 1) qty = 1;
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
    const totalInput = document.getElementById(`cartPriceInput_${index}`);
    if (totalInput) totalInput.value = rowTotal.toFixed(2);

    calculateTotals();
    updateCatalogSelectionIndicators();
}

function onCartItemPriceInput(index, val) {
    const item = cart[index];
    if (!item) return;

    let price = parseFloat(val);
    if (isNaN(price) || price < 0) price = 0;

    item.unitPrice = price;
    calculateTotals();
    updateCatalogSelectionIndicators();
}

function removeFromCart(index) {
    cart.splice(index, 1);
    renderCart();
    updateCatalogSelectionIndicators();
}

function clearCart() {
    if (cart.length === 0) return;
    cart = [];
    payments = [];
    discountAmount = 0.0;
    discountPercent = 0.0;
    const discInput = document.getElementById('discountAmountInput');
    if (discInput) discInput.value = '0.00';
    const discPctInput = document.getElementById('discountPercentInput');
    if (discPctInput) discPctInput.value = '0';
    renderCart();
    renderPaymentsList();
    updateCatalogSelectionIndicators();
}

function renderCart() {
    const container = document.getElementById('cartItemsList');
    const placeholder = document.getElementById('cartEmptyPlaceholder');
    if (!container || !placeholder) return;

    if (cart.length === 0) {
        placeholder.classList.remove('d-none');
        container.classList.add('d-none');
        container.innerHTML = '';
        calculateTotals();
        return;
    }

    placeholder.classList.add('d-none');
    container.classList.remove('d-none');

    let html = '';
    cart.forEach((item, index) => {
        const rowTotal = (item.unitPrice * item.quantity) - item.discountAmount;
        html += `
            <div class="cart-item-row d-flex align-items-center gap-1 mb-1 p-1 bg-white rounded border">
                <div class="flex-grow-1 text-truncate">
                    <input type="text" class="form-control form-control-sm bg-light text-dark fw-semibold text-truncate p-1 border-0" 
                           value="${item.name}" readonly title="${item.name}" style="font-size: 0.82rem;" />
                </div>
                <div class="input-group input-group-sm" style="width: 82px;">
                    <button class="btn btn-outline-secondary p-0 px-1" type="button" onclick="stepCartQty(${index}, -1)">-</button>
                    <input type="number" class="form-control text-center p-0 fw-bold" id="cartQtyInput_${index}" 
                           min="1" max="${item.currentStock}" value="${item.quantity}" oninput="onCartItemQtyInput(${index}, this.value)" style="font-size: 0.85rem;" />
                    <button class="btn btn-outline-secondary p-0 px-1" type="button" onclick="stepCartQty(${index}, 1)">+</button>
                </div>
                <div style="width: 78px;">
                    <input type="number" step="any" min="0" class="form-control form-control-sm text-end fw-semibold p-1" 
                           id="cartPriceInput_${index}" value="${item.unitPrice.toFixed(2)}" oninput="onCartItemPriceInput(${index}, this.value)" style="font-size: 0.82rem;" />
                </div>
                <div>
                    <button type="button" class="btn btn-sm btn-link text-danger p-0 px-1" onclick="removeFromCart(${index})" title="Delete item">
                        <i class="bi bi-trash fs-6"></i>
                    </button>
                </div>
            </div>
        `;
    });

    container.innerHTML = html;
    calculateTotals();
}

function updateCatalogSelectionIndicators() {
    const inCartMap = new Map();
    cart.forEach(item => inCartMap.set(item.productId, item.quantity));

    document.querySelectorAll('.pos-product-item').forEach(col => {
        const prodId = parseInt(col.dataset.id);
        const card = document.getElementById(`posProductCard_${prodId}`);
        const badge = document.getElementById(`cardSelectedBadge_${prodId}`);
        const qtyEl = document.getElementById(`cardSelectedQty_${prodId}`);

        if (inCartMap.has(prodId) && inCartMap.get(prodId) > 0) {
            card?.classList.add('selected-active');
            if (badge) badge.classList.remove('d-none');
            if (qtyEl) qtyEl.innerText = inCartMap.get(prodId);
        } else {
            card?.classList.remove('selected-active');
            if (badge) badge.classList.add('d-none');
        }
    });
}

// -------------------------------------------------------------
// Totals & Calculations with Discount % and Discount Amount
// -------------------------------------------------------------

function onDiscountPercentInput(val) {
    discountPercent = parseFloat(val) || 0.0;
    if (discountPercent < 0) discountPercent = 0.0;
    if (discountPercent > 100) discountPercent = 100.0;

    const subtotal = cart.reduce((sum, item) => sum + (item.unitPrice * item.quantity), 0);
    discountAmount = (subtotal * discountPercent) / 100.0;

    const discAmtInput = document.getElementById('discountAmountInput');
    if (discAmtInput) discAmtInput.value = discountAmount.toFixed(2);

    calculateTotals();
}

function onDiscountAmountInput(val) {
    discountAmount = parseFloat(val) || 0.0;
    if (discountAmount < 0) discountAmount = 0.0;

    const subtotal = cart.reduce((sum, item) => sum + (item.unitPrice * item.quantity), 0);
    discountPercent = subtotal > 0 ? (discountAmount / subtotal) * 100.0 : 0.0;

    const discPctInput = document.getElementById('discountPercentInput');
    if (discPctInput) discPctInput.value = discountPercent > 0 ? discountPercent.toFixed(1) : '0';

    calculateTotals();
}

function calculateTotals() {
    const subtotal = cart.reduce((sum, item) => sum + (item.unitPrice * item.quantity), 0);

    // If discount % was entered, keep amount synchronized with subtotal changes
    if (discountPercent > 0) {
        discountAmount = (subtotal * discountPercent) / 100.0;
        const discAmtInput = document.getElementById('discountAmountInput');
        if (discAmtInput && document.activeElement !== discAmtInput) {
            discAmtInput.value = discountAmount.toFixed(2);
        }
    }

    const taxableAmount = Math.max(0, subtotal - discountAmount);
    const vatAmount = (taxableAmount * (taxRate / 100));
    const sdAmount = (taxableAmount * (sdRate / 100));
    const grandTotal = taxableAmount + vatAmount + sdAmount;

    // Payments calculation
    const totalPaymentsAdded = payments.reduce((sum, p) => sum + p.amount, 0);
    // If no payment line manually added, Paid matches Grand Total by default
    const paidAmount = payments.length > 0 ? totalPaymentsAdded : (grandTotal > 0 ? grandTotal : 0.0);
    const remainingAmount = Math.max(0, grandTotal - paidAmount);
    const changeDue = Math.max(0, paidAmount - grandTotal);

    document.getElementById('lblSubtotal')?.replaceChildren(document.createTextNode(subtotal.toFixed(2)));
    document.getElementById('lblTax')?.replaceChildren(document.createTextNode(vatAmount.toFixed(2)));
    document.getElementById('lblSd')?.replaceChildren(document.createTextNode(sdAmount.toFixed(2)));
    document.getElementById('lblGrandTotal')?.replaceChildren(document.createTextNode(grandTotal.toFixed(2)));
    document.getElementById('lblPaid')?.replaceChildren(document.createTextNode(paidAmount.toFixed(2)));
    document.getElementById('lblChangeDue')?.replaceChildren(document.createTextNode(changeDue.toFixed(2)));
    document.getElementById('lblRemaining')?.replaceChildren(document.createTextNode(remainingAmount.toFixed(2)));

    return { subtotal, discountAmount, vatAmount, grandTotal, paidAmount, remainingAmount, changeDue };
}

// -------------------------------------------------------------
// Payments Section matching Screenshot 1 (Fill remaining, Add)
// -------------------------------------------------------------

function fillRemainingPayment() {
    const { remainingAmount, grandTotal } = calculateTotals();
    const payInput = document.getElementById('paymentAmountInput');
    if (payInput) {
        payInput.value = (remainingAmount > 0 ? remainingAmount : grandTotal).toFixed(2);
    }
}

function addPaymentRow() {
    const typeSelect = document.getElementById('paymentTypeSelect');
    const payInput = document.getElementById('paymentAmountInput');
    const type = typeSelect ? typeSelect.value : 'Cash';
    const amount = parseFloat(payInput?.value) || 0;

    if (amount <= 0) {
        Swal.fire({
            icon: 'warning',
            title: 'Invalid Amount',
            text: 'Please enter a valid payment amount.',
            timer: 1500,
            showConfirmButton: false
        });
        return;
    }

    payments.push({ type, amount });
    if (payInput) payInput.value = '';
    renderPaymentsList();
    calculateTotals();
}

function removePaymentRow(index) {
    payments.splice(index, 1);
    renderPaymentsList();
    calculateTotals();
}

function renderPaymentsList() {
    const listEl = document.getElementById('addedPaymentsList');
    if (!listEl) return;

    if (payments.length === 0) {
        listEl.innerHTML = '';
        return;
    }

    let html = '';
    payments.forEach((p, idx) => {
        html += `
            <div class="d-flex justify-content-between align-items-center py-1 px-2 mb-1 bg-white border rounded small">
                <span class="badge bg-secondary text-uppercase">${p.type}</span>
                <span class="fw-bold text-dark">৳ ${p.amount.toFixed(2)}</span>
                <button type="button" class="btn btn-sm btn-link text-danger p-0" onclick="removePaymentRow(${idx})">
                    <i class="bi bi-trash"></i>
                </button>
            </div>
        `;
    });
    listEl.innerHTML = html;
}

// -------------------------------------------------------------
// Park / Hold Order & Drafts (Screenshot 1: Park, Drafts (0))
// -------------------------------------------------------------

function getParkedOrders() {
    try {
        return JSON.parse(localStorage.getItem('pos_parked_orders') || '[]');
    } catch {
        return [];
    }
}

function saveParkedOrders(orders) {
    localStorage.setItem('pos_parked_orders', JSON.stringify(orders));
    updateParkedOrdersCount();
}

function updateParkedOrdersCount() {
    const countEl = document.getElementById('draftsCount');
    if (countEl) {
        countEl.innerText = getParkedOrders().length;
    }
}

function parkCurrentOrder() {
    if (cart.length === 0) {
        Swal.fire('Empty Order', 'Cannot park an empty order.', 'warning');
        return;
    }

    const { grandTotal } = calculateTotals();
    const customerSelect = document.getElementById('posCustomerSelect');
    const customerName = customerSelect?.options[customerSelect.selectedIndex]?.text || 'Walk-in';

    const parked = getParkedOrders();
    parked.push({
        id: Date.now(),
        time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        customerName: customerName,
        customerId: customerSelect?.value || '1',
        cart: [...cart],
        payments: [...payments],
        discountAmount: discountAmount,
        grandTotal: grandTotal
    });

    saveParkedOrders(parked);
    clearCart();

    Swal.fire({
        icon: 'info',
        title: 'Order Parked',
        text: 'Order has been parked. You can restore it anytime from Drafts.',
        timer: 1600,
        showConfirmButton: false
    });
}

function openDraftsModal() {
    const parked = getParkedOrders();
    const tbody = document.getElementById('draftsTableBody');
    if (!tbody) return;

    if (parked.length === 0) {
        tbody.innerHTML = `<tr><td colspan="5" class="text-center text-muted py-4">No parked orders found.</td></tr>`;
    } else {
        let html = '';
        parked.forEach((draft, idx) => {
            html += `
                <tr>
                    <td class="fw-bold">${idx + 1}</td>
                    <td>${draft.time}<br/><small class="text-muted">${draft.customerName}</small></td>
                    <td>${draft.cart.length} items (${draft.cart.reduce((s, i) => s + i.quantity, 0)} pcs)</td>
                    <td class="text-end fw-bold">৳ ${draft.grandTotal.toFixed(2)}</td>
                    <td class="text-center">
                        <button class="btn btn-sm btn-success px-2 py-0 me-1" onclick="restoreParkedOrder(${idx})">Restore</button>
                        <button class="btn btn-sm btn-outline-danger px-2 py-0" onclick="deleteParkedOrder(${idx})"><i class="bi bi-trash"></i></button>
                    </td>
                </tr>
            `;
        });
        tbody.innerHTML = html;
    }

    const modalEl = document.getElementById('draftsModal');
    if (modalEl) {
        bootstrap.Modal.getOrCreateInstance(modalEl).show();
    }
}

function restoreParkedOrder(idx) {
    const parked = getParkedOrders();
    const order = parked[idx];
    if (!order) return;

    cart = order.cart;
    payments = order.payments || [];
    discountAmount = order.discountAmount || 0;
    const discInput = document.getElementById('discountAmountInput');
    if (discInput) discInput.value = discountAmount.toFixed(2);

    const custSelect = document.getElementById('posCustomerSelect');
    if (custSelect && order.customerId) {
        custSelect.value = order.customerId;
    }

    parked.splice(idx, 1);
    saveParkedOrders(parked);

    const modalEl = document.getElementById('draftsModal');
    if (modalEl) bootstrap.Modal.getInstance(modalEl)?.hide();

    renderCart();
    renderPaymentsList();
    updateCatalogSelectionIndicators();
}

function deleteParkedOrder(idx) {
    const parked = getParkedOrders();
    parked.splice(idx, 1);
    saveParkedOrders(parked);
    openDraftsModal();
}

// -------------------------------------------------------------
// Quick Add Customer Modal
// -------------------------------------------------------------

function openAddCustomerQuickModal() {
    const modalEl = document.getElementById('quickAddCustomerModal');
    if (modalEl) {
        bootstrap.Modal.getOrCreateInstance(modalEl).show();
    }
}

function submitQuickCustomer() {
    const name = document.getElementById('quickCustName')?.value.trim();
    const phone = document.getElementById('quickCustPhone')?.value.trim();
    const address = document.getElementById('quickCustAddress')?.value.trim();

    if (!name) {
        Swal.fire('Required', 'Please enter customer name.', 'warning');
        return;
    }

    fetch('/Pos/QuickAddCustomer', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, phone, address })
    })
    .then(r => r.json())
    .then(res => {
        if (res.success) {
            const select = document.getElementById('posCustomerSelect');
            if (select) {
                const opt = document.createElement('option');
                opt.value = res.id;
                opt.text = `${res.name} (${res.phone || 'N/A'})`;
                opt.selected = true;
                select.appendChild(opt);
            }
            const modalEl = document.getElementById('quickAddCustomerModal');
            if (modalEl) bootstrap.Modal.getInstance(modalEl)?.hide();
            Swal.fire({
                icon: 'success',
                title: 'Customer Added',
                text: `${name} has been selected.`,
                timer: 1500,
                showConfirmButton: false
            });
        } else {
            Swal.fire('Error', res.message || 'Could not add customer.', 'error');
        }
    })
    .catch(err => {
        console.error(err);
        Swal.fire('Error', 'Server communication error.', 'error');
    });
}

// -------------------------------------------------------------
// Save Sale Order (Saves to DB, inserts into Sales & SaleItems,
// and shows in Sales Table / Index as requested by user)
// -------------------------------------------------------------

function saveSaleOrder(isPosted = true, shouldPrint = false) {
    if (cart.length === 0) {
        Swal.fire('Empty Order', 'Please select at least one product before saving.', 'warning');
        return;
    }

    const { subtotal, discountAmount, vatAmount, grandTotal, paidAmount, changeDue } = calculateTotals();
    const customerSelect = document.getElementById('posCustomerSelect');
    const customerId = parseInt(customerSelect?.value) || 1;
    const ref = document.getElementById('posReferenceInput')?.value.trim() || 'NA';
    const remarks = document.getElementById('posRemarksInput')?.value.trim() || '';

    // Payment method string
    let effectivePaymentMethod = 'Cash';
    if (payments.length > 0) {
        effectivePaymentMethod = payments.map(p => `${p.type}: ${p.amount}`).join(', ');
    }

    const payload = {
        CustomerId: customerId,
        SubTotal: subtotal,
        TaxRate: taxRate,
        TaxAmount: vatAmount,
        DiscountPercent: discountPercent,
        DiscountAmount: discountAmount,
        GrandTotal: grandTotal,
        PaidAmount: paidAmount > 0 ? paidAmount : grandTotal,
        ChangeAmount: changeDue,
        PaymentMethod: effectivePaymentMethod,
        Notes: remarks ? `${ref} | ${remarks}` : ref,
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

    Swal.fire({
        title: 'Saving Sale Order...',
        text: 'Recording sale into database tables',
        allowOutsideClick: false,
        didOpen: () => Swal.showLoading()
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
            const statusEl = document.getElementById('posLastSaleStatus');
            if (statusEl) statusEl.innerText = `Last sale: ${data.invoiceNumber} (posted)`;

            if (shouldPrint) {
                // If POS Print is requested, show print modal with option to view Sales Table
                document.getElementById('modalInvoiceNo').innerText = data.invoiceNumber;
                const iframe = document.getElementById('posInvoiceFrame');
                if (iframe) iframe.src = `/Sales/GetReport/${data.saleId}`;
                const modalEl = document.getElementById('posInvoiceModal');
                if (modalEl) bootstrap.Modal.getOrCreateInstance(modalEl).show();

                // Show floating toast matching Screenshot 1
                showSavedToast(data.invoiceNumber, data.saleId);
            } else {
                // User Requirement:
                // "jokhon save button a click korbo tokhon Sales Table Data Dekhabe and salse index a show hobe"
                // Redirect directly to Sales Index where newly saved invoice is displayed at the top!
                window.location.href = `/Sales/Index?newInvoice=${encodeURIComponent(data.invoiceNumber)}`;
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

function showSavedToast(invNo, saleId) {
    const toast = document.getElementById('posSavedBottomToast');
    const toastInv = document.getElementById('toastInvoiceNo');
    if (toast && toastInv) {
        toastInv.innerText = invNo;
        toast.classList.remove('d-none');
        toast.classList.add('d-flex');
    }
}

function hideSavedToast() {
    const toast = document.getElementById('posSavedBottomToast');
    if (toast) {
        toast.classList.add('d-none');
        toast.classList.remove('d-flex');
    }
}

function printPosInvoice() {
    const iframe = document.getElementById('posInvoiceFrame');
    if (iframe && iframe.contentWindow) {
        iframe.contentWindow.focus();
        iframe.contentWindow.print();
    }
}

function resetPosForNextOrder() {
    clearCart();
    fetchNextInvoiceNumber();
    document.getElementById('posSearchInput')?.focus();
}

function fetchNextInvoiceNumber() {
    fetch('/Sales/GetNextInvoiceNo')
        .then(r => r.json())
        .then(res => {
            if (res.success && res.invoiceNo) {
                const codeEl = document.getElementById('posCurrentInvoiceCode');
                if (codeEl) codeEl.innerText = res.invoiceNo;
            }
        })
        .catch(() => {});
}
