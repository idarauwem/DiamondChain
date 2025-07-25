;; DiamondChain - Diamond Authenticity Verification System
;; Version: 1.0.0
;; Track diamond authenticity from mine to market with certification

(define-map diamonds uint {
  miner: principal,
  diamond-grade: (string-utf8 64),
  certification-details: (string-utf8 256),
  extraction-date: uint,
  mining-location: (string-utf8 64),
  authenticity-verified: bool
})

(define-map miner-stones principal (list 100 uint))
(define-map gemology-experts principal bool)
(define-data-var stone-id-tracker uint u0)

;; Error codes
(define-constant err-not-miner (err u400))
(define-constant err-not-expert (err u401))
(define-constant err-diamond-not-found (err u402))
(define-constant err-permission-denied (err u403))
(define-constant err-stone-limit-reached (err u404))
(define-constant err-invalid-expert-address (err u405))
(define-constant err-invalid-diamond-grade (err u406))
(define-constant err-invalid-certification (err u407))
(define-constant err-invalid-extraction-date (err u408))
(define-constant err-invalid-location-name (err u409))
(define-constant err-invalid-stone-id (err u410))

;; Contract supervisor for authenticity control
(define-constant contract-supervisor tx-sender)

;; Register gemology expert
(define-public (register-gemology-expert (expert principal))
  (begin
    ;; Check if sender is contract supervisor
    (asserts! (is-eq tx-sender contract-supervisor) err-permission-denied)
    
    ;; Validate expert principal
    (asserts! (not (is-eq expert 'SP000000000000000000002Q6VF78)) err-invalid-expert-address)
    
    ;; Add expert to registry
    (ok (map-set gemology-experts expert true))
  ))

;; Register diamond stone
(define-public (register-diamond-stone
  (diamond-grade (string-utf8 64))
  (certification-details (string-utf8 256))
  (extraction-date uint)
  (mining-location (string-utf8 64)))
  (let
    ((stone-id (var-get stone-id-tracker))
     (miner tx-sender)
     (current-stones (default-to (list) (map-get? miner-stones miner))))
    
    ;; Validate inputs
    (asserts! (> (len diamond-grade) u0) err-invalid-diamond-grade)
    (asserts! (> (len certification-details) u0) err-invalid-certification)
    (asserts! (> extraction-date u0) err-invalid-extraction-date)
    (asserts! (> (len mining-location) u0) err-invalid-location-name)
    
    ;; Check stone registration limit
    (asserts! (< (len current-stones) u100) err-stone-limit-reached)
    
    ;; Store diamond information
    (map-set diamonds stone-id {
      miner: miner,
      diamond-grade: diamond-grade,
      certification-details: certification-details,
      extraction-date: extraction-date,
      mining-location: mining-location,
      authenticity-verified: false
    })
    
    ;; Update miner's stone list
    (let
      ((updated-stone-list (unwrap-panic (as-max-len? (concat (list stone-id) current-stones) u100))))
      (map-set miner-stones miner updated-stone-list)
    )
    
    ;; Increment stone ID tracker
    (var-set stone-id-tracker (+ stone-id u1))
    
    (ok stone-id)))

;; Verify diamond authenticity
(define-public (verify-diamond-authenticity (stone-id uint))
  (begin
    ;; Validate stone ID
    (asserts! (< stone-id (var-get stone-id-tracker)) err-invalid-stone-id)
    
    (let
      ((diamond (unwrap! (map-get? diamonds stone-id) err-diamond-not-found)))
      
      ;; Check if sender is gemology expert
      (asserts! (default-to false (map-get? gemology-experts tx-sender)) err-not-expert)
      
      ;; Update diamond authenticity verification status
      (ok (map-set diamonds stone-id (merge diamond {authenticity-verified: true})))
    )
  ))

;; Get diamond details
(define-read-only (get-diamond (stone-id uint))
  (map-get? diamonds stone-id))

;; Get miner's stones
(define-read-only (get-miner-stones (miner principal))
  (default-to (list) (map-get? miner-stones miner)))

;; Check gemology expert status
(define-read-only (is-gemology-expert (address principal))
  (default-to false (map-get? gemology-experts address)))

;; Get total stones
(define-read-only (get-total-stones)
  (var-get stone-id-tracker))

;; Get contract stats
(define-read-only (get-contract-stats)
  {
    supervisor: contract-supervisor,
    total-stones: (var-get stone-id-tracker)
  })