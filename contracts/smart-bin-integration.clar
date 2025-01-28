;; Smart Bin Integration Contract

(define-map smart-bins
  { bin-id: (string-ascii 50) }
  {
    location: (string-ascii 100),
    capacity: uint,
    current-fill: uint,
    last-updated: uint
  }
)

(define-public (register-smart-bin
  (bin-id (string-ascii 50))
  (location (string-ascii 100))
  (capacity uint)
)
  (begin
    (asserts! (is-authorized-bin-manager tx-sender) (err u403))
    (ok (map-set smart-bins
      { bin-id: bin-id }
      {
        location: location,
        capacity: capacity,
        current-fill: u0,
        last-updated: block-height
      }
    ))
  )
)

(define-public (update-bin-status
  (bin-id (string-ascii 50))
  (current-fill uint)
)
  (let
    ((bin (unwrap! (map-get? smart-bins { bin-id: bin-id }) (err u404))))
    (asserts! (is-authorized-bin-updater tx-sender) (err u403))
    (ok (map-set smart-bins
      { bin-id: bin-id }
      (merge bin {
        current-fill: current-fill,
        last-updated: block-height
      })
    ))
  )
)

(define-read-only (get-bin-status (bin-id (string-ascii 50)))
  (map-get? smart-bins { bin-id: bin-id })
)

(define-constant AUTHORIZED_BIN_MANAGERS
  (list
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
    'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
  )
)

(define-constant AUTHORIZED_BIN_UPDATERS
  (list
    'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC
    'ST2NEB84ASENDXKYGJPQW86YXQCEFEX2ZQPG87ND
  )
)

(define-read-only (is-authorized-bin-manager (address principal))
  (is-some (index-of AUTHORIZED_BIN_MANAGERS address))
)

(define-read-only (is-authorized-bin-updater (address principal))
  (is-some (index-of AUTHORIZED_BIN_UPDATERS address))
)

