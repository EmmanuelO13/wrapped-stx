;; --------------------------------------------
;; Wrapped STX (wSTX) Fungible Token Contract
;; --------------------------------------------

(define-constant ERR_INSUFFICIENT_STX u100)
(define-constant ERR_INSUFFICIENT_WSTX u101)
(define-constant ERR_UNAUTHORIZED u102)
(define-constant ERR_ZERO_AMOUNT u103)

;; Token metadata
(define-constant TOKEN_NAME "Wrapped STX")
(define-constant TOKEN_SYMBOL "wSTX")
(define-constant TOKEN_DECIMALS u6)

;; Total supply variable
(define-data-var total-supply uint u0)

;; Map of user balances
(define-map balances principal uint)

;; Map of allowances for SIP-010 approve/transfer-from (optional)
(define-map allowances { owner: principal, spender: principal } uint)

;; ----------------------------------
;; SIP-010 Required Read-Only Functions
;; ----------------------------------

(define-read-only (get-name) (ok TOKEN_NAME))
(define-read-only (get-symbol) (ok TOKEN_SYMBOL))
(define-read-only (get-decimals) (ok TOKEN_DECIMALS))

(define-read-only (get-total-supply) (ok (var-get total-supply)))

(define-read-only (get-balance (owner principal))
  (ok (default-to u0 (map-get? balances owner))))

(define-read-only (get-allowance (owner principal) (spender principal))
  (ok (default-to u0 (map-get? allowances { owner: owner, spender: spender }))))


;; ----------------------------------
;; Internal functions: mint & burn
;; ----------------------------------

(define-private (mint (recipient principal) (amount uint))
  (begin
    (var-set total-supply (+ (var-get total-supply) amount))
    (map-set balances recipient (+ (default-to u0 (map-get? balances recipient)) amount))
    (ok true)))

(define-private (burn (owner principal) (amount uint))
  (let ((balance (default-to u0 (map-get? balances owner))))
    (if (>= balance amount)
        (begin
          (map-set balances owner (- balance amount))
          (var-set total-supply (- (var-get total-supply) amount))
          (ok true))
        (err ERR_INSUFFICIENT_WSTX))))


;; ----------------------------------
;; Public Functions
;; ----------------------------------

;; Wrap STX: send STX and mint wSTX 1:1
(define-public (wrap)
  (let ((amount (stx-get-transfer-amount)))
    (if (<= amount u0)
        (err ERR_ZERO_AMOUNT)
        (begin
          ;; Mint wSTX to sender
          (mint tx-sender amount)))))


;; ----------------------------------
;; SIP-010 transfer function
;; ----------------------------------

(define-public (transfer (recipient principal) (amount uint))
  (let ((sender-balance (default-to u0 (map-get? balances tx-sender))))
    (if (or (<= amount u0) (< sender-balance amount))
        (err ERR_INSUFFICIENT_WSTX)
        (begin
          (map-set balances tx-sender (- sender-balance amount))
          (map-set balances recipient (+ (default-to u0 (map-get? balances recipient)) amount))
          (ok true)))))

;; ----------------------------------
;; SIP-010 approve and transfer-from (optional)
;; ----------------------------------

(define-public (approve (spender principal) (amount uint))
  (begin
    (map-set allowances { owner: tx-sender, spender: spender } amount)
    (ok true)))

(define-public (transfer-from (owner principal) (recipient principal) (amount uint))
  (let ((allowance (default-to u0 (map-get? allowances { owner: owner, spender: tx-sender })))
        (owner-balance (default-to u0 (map-get? balances owner))))
    (if (or (<= amount u0) (< allowance amount) (< owner-balance amount))
        (err ERR_INSUFFICIENT_WSTX)
        (begin
          ;; deduct allowance
          (map-set allowances { owner: owner, spender: tx-sender } (- allowance amount))
          ;; transfer tokens
          (map-set balances owner (- owner-balance amount))
          (map-set balances recipient (+ (default-to u0 (map-get? balances recipient)) amount))
          (ok true)))))

;; ----------------------------------
;; Helper: get STX amount sent with tx
;; ----------------------------------

(define-private (stx-get-transfer-amount)
  (let ((amount (stx-get-balance tx-sender)))
    ;; Note: You may need to adjust based on contract usage or use a different pattern to get STX sent
    amount))

