;; Recycling Achievement NFT Contract

(define-non-fungible-token recycling-achievement uint)

(define-map achievement-info
  { achievement-id: uint }
  {
    title: (string-ascii 100),
    description: (string-utf8 500),
    recipient: principal,
    awarded-at: uint
  }
)

(define-data-var achievement-id-nonce uint u0)

(define-public (award-achievement
  (recipient principal)
  (title (string-ascii 100))
  (description (string-utf8 500))
)
  (let
    ((new-achievement-id (+ (var-get achievement-id-nonce) u1)))
    (asserts! (is-authorized-awarder tx-sender) (err u403))
    (try! (nft-mint? recycling-achievement new-achievement-id recipient))
    (map-set achievement-info
      { achievement-id: new-achievement-id }
      {
        title: title,
        description: description,
        recipient: recipient,
        awarded-at: block-height
      }
    )
    (var-set achievement-id-nonce new-achievement-id)
    (ok new-achievement-id)
  )
)

(define-read-only (get-achievement-info (achievement-id uint))
  (map-get? achievement-info { achievement-id: achievement-id })
)

(define-constant AUTHORIZED_AWARDERS
  (list
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
    'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
  )
)

(define-read-only (is-authorized-awarder (address principal))
  (is-some (index-of AUTHORIZED_AWARDERS address))
)

