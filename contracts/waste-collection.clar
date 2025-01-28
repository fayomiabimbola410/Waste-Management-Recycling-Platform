;; Waste Collection Contract

(define-map collection-schedules
  { area-id: uint }
  {
    next-collection: uint,
    frequency: uint,
    waste-type: (string-ascii 20)
  }
)

(define-map collection-records
  { record-id: uint }
  {
    area-id: uint,
    collector: principal,
    timestamp: uint,
    waste-amount: uint,
    waste-type: (string-ascii 20)
  }
)

(define-data-var record-id-nonce uint u0)

(define-public (set-collection-schedule
  (area-id uint)
  (next-collection uint)
  (frequency uint)
  (waste-type (string-ascii 20))
)
  (begin
    (asserts! (is-authorized-scheduler tx-sender) (err u403))
    (ok (map-set collection-schedules
      { area-id: area-id }
      {
        next-collection: next-collection,
        frequency: frequency,
        waste-type: waste-type
      }
    ))
  )
)

(define-public (record-waste-collection
  (area-id uint)
  (waste-amount uint)
  (waste-type (string-ascii 20))
)
  (let
    ((new-record-id (+ (var-get record-id-nonce) u1)))
    (asserts! (is-authorized-collector tx-sender) (err u403))
    (map-set collection-records
      { record-id: new-record-id }
      {
        area-id: area-id,
        collector: tx-sender,
        timestamp: block-height,
        waste-amount: waste-amount,
        waste-type: waste-type
      }
    )
    (var-set record-id-nonce new-record-id)
    (ok new-record-id)
  )
)

(define-read-only (get-collection-schedule (area-id uint))
  (map-get? collection-schedules { area-id: area-id })
)

(define-read-only (get-collection-record (record-id uint))
  (map-get? collection-records { record-id: record-id })
)

(define-constant AUTHORIZED_SCHEDULERS
  (list
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
    'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
  )
)

(define-constant AUTHORIZED_COLLECTORS
  (list
    'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC
    'ST2NEB84ASENDXKYGJPQW86YXQCEFEX2ZQPG87ND
  )
)

(define-read-only (is-authorized-scheduler (address principal))
  (is-some (index-of AUTHORIZED_SCHEDULERS address))
)

(define-read-only (is-authorized-collector (address principal))
  (is-some (index-of AUTHORIZED_COLLECTORS address))
)

