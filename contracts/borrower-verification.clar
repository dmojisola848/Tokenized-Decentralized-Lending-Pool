;; Borrower Verification Contract
;; Purpose: Validates loan recipients and maintains a registry of eligible borrowers

(define-map verified-borrowers principal bool)
(define-map borrower-credit-scores principal uint)
(define-map borrower-loan-counts principal uint)

;; Error codes
(define-constant ERR-NOT-VERIFIED u200)
(define-constant ERR-ALREADY-VERIFIED u201)

;; Check if a borrower is verified
(define-read-only (is-verified-borrower (borrower principal))
  (default-to false (map-get? verified-borrowers borrower))
)

;; Get borrower's credit score
(define-read-only (get-credit-score (borrower principal))
  (default-to u0 (map-get? borrower-credit-scores borrower))
)

;; Get count of loans taken by borrower
(define-read-only (get-loan-count (borrower principal))
  (default-to u0 (map-get? borrower-loan-counts borrower))
)

;; Register as a verified borrower
(define-public (register-borrower (initial-credit-score uint))
  (let (
    (sender tx-sender)
  )
    (asserts! (not (is-verified-borrower sender)) (err ERR-ALREADY-VERIFIED))

    (map-set verified-borrowers sender true)
    (map-set borrower-credit-scores sender initial-credit-score)
    (map-set borrower-loan-counts sender u0)
    (ok true)
  )
)

;; Update borrower's credit score (restricted to authorized parties)
(define-public (update-credit-score (borrower principal) (new-score uint))
  (begin
    ;; In a real implementation, this would check if the caller is authorized
    (asserts! (is-verified-borrower borrower) (err ERR-NOT-VERIFIED))
    (map-set borrower-credit-scores borrower new-score)
    (ok true)
  )
)

;; Increment borrower's loan count when they take a new loan
(define-public (increment-loan-count (borrower principal))
  (let (
    (current-count (get-loan-count borrower))
  )
    (asserts! (is-verified-borrower borrower) (err ERR-NOT-VERIFIED))
    (map-set borrower-loan-counts borrower (+ current-count u1))
    (ok true)
  )
)

;; Unregister a borrower
(define-public (unregister-borrower)
  (let (
    (sender tx-sender)
  )
    (asserts! (is-verified-borrower sender) (err ERR-NOT-VERIFIED))

    (map-delete verified-borrowers sender)
    (map-delete borrower-credit-scores sender)
    (map-delete borrower-loan-counts sender)
    (ok true)
  )
)
