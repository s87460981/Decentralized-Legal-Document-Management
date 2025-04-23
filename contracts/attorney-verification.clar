;; Attorney Verification Contract
;; This contract validates the credentials of legal professionals

(define-data-var admin principal tx-sender)

;; Map of verified attorneys
(define-map attorneys
  { attorney-id: principal }
  {
    name: (string-utf8 100),
    license-number: (string-utf8 50),
    jurisdiction: (string-utf8 50),
    verified: bool,
    verification-date: uint
  }
)

;; Public function to register an attorney (only admin can verify)
(define-public (register-attorney (name (string-utf8 100)) (license-number (string-utf8 50)) (jurisdiction (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can register
    (ok (map-set attorneys
      { attorney-id: tx-sender }
      {
        name: name,
        license-number: license-number,
        jurisdiction: jurisdiction,
        verified: false,
        verification-date: u0
      }
    ))
  )
)

;; Public function to verify an attorney
(define-public (verify-attorney (attorney-id principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can verify
    (asserts! (is-some (map-get? attorneys { attorney-id: attorney-id })) (err u2)) ;; Attorney must be registered
    (ok (map-set attorneys
      { attorney-id: attorney-id }
      (merge (unwrap-panic (map-get? attorneys { attorney-id: attorney-id }))
        {
          verified: true,
          verification-date: block-height
        }
      )
    ))
  )
)

;; Read-only function to check if an attorney is verified
(define-read-only (is-attorney-verified (attorney-id principal))
  (match (map-get? attorneys { attorney-id: attorney-id })
    attorney (get verified attorney)
    false
  )
)

;; Read-only function to get attorney details
(define-read-only (get-attorney-details (attorney-id principal))
  (map-get? attorneys { attorney-id: attorney-id })
)

;; Function to change admin (only current admin can change)
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (var-set admin new-admin))
  )
)
