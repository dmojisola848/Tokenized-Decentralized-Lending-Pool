;; Lender Verification Contract
;; Purpose: Validates funding sources and maintains a registry of approved lenders

(define-data-var minimum-stake uint u1000)
(define-map approved-lenders principal bool)
(define-map lender-stakes principal uint)

;; Error codes
(define-constant ERR-NOT-APPROVED u100)
(define-constant ERR-INSUFFICIENT-STAKE u101)
(define-constant ERR-ALREADY-REGISTERED u102)

;; Get minimum stake required to be a lender
(define-read-only (get-minimum-stake)
  (var-get minimum-stake)
)

;; Check if a lender is approved
(define-read-only (is-approved-lender (lender principal))
  (default-to false (map-get? approved-lenders lender))
)

;; Get lender's staked amount
(define-read-only (get-lender-stake (lender principal))
  (default-to u0 (map-get? lender-stakes lender))
)

;; Register as a lender by staking tokens
(define-public (register-lender (stake-amount uint))
  (let (
    (sender tx-sender)
    (min-stake (var-get minimum-stake))
  )
    (asserts! (>= stake-amount min-stake) (err ERR-INSUFFICIENT-STAKE))
    (asserts! (not (is-approved-lender sender)) (err ERR-ALREADY-REGISTERED))

    ;; In a real implementation, this would transfer tokens from the sender to this contract
    ;; For simplicity, we're just recording the stake
    (map-set lender-stakes sender stake-amount)
    (map-set approved-lenders sender true)
    (ok true)
  )
)

;; Unregister as a lender and reclaim stake
(define-public (unregister-lender)
  (let (
    (sender tx-sender)
  )
    (asserts! (is-approved-lender sender) (err ERR-NOT-APPROVED))

    ;; In a real implementation, this would transfer tokens back to the sender
    (map-delete lender-stakes sender)
    (map-delete approved-lenders sender)
    (ok true)
  )
)

;; Update the minimum stake required (restricted to contract owner)
(define-public (update-minimum-stake (new-minimum uint))
  (begin
    ;; In a real implementation, this would check if the caller is the contract owner
    (var-set minimum-stake new-minimum)
    (ok true)
  )
)
