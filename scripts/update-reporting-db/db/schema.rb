# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "claim_lines", id: false, force: :cascade do |t|
    t.string "claim-doc-id", limit: 64
    t.string "claim-reference-number", limit: 32
    t.string "pa-name", limit: 8
    t.string "ip-name", limit: 1024
    t.string "ip-code", limit: 8
    t.string "type", limit: 32
    t.float "fund"
    t.float "public"
    t.float "fric-cap"
    t.float "fric-rev"
    t.float "frpp-cap"
    t.float "frpp-rev"
    t.float "fund-cap-intervention-rate"
    t.float "fund-rev-intervention-rate"
    t.float "fund-tot-intervention-rate"
    t.float "public-cap-intervention-rate"
    t.float "public-rev-intervention-rate"
    t.float "public-tot-intervention-rate"
    t.float "private-cap-intervention-rate"
    t.float "private-rev-intervention-rate"
    t.float "private-tot-intervention-rate"
    t.float "eligible-cap-expenditure"
    t.float "eligible-rev-expenditure"
    t.float "total-cap-expenditure"
    t.float "total-rev-expenditure"
    t.float "fund-cap-expenditure"
    t.float "fund-rev-expenditure"
    t.float "public-cap-expenditure"
    t.float "public-rev-expenditure"
    t.float "private-cap-expenditure"
    t.float "private-rev-expenditure"
  end

  create_table "claims", id: false, force: :cascade do |t|
    t.string "claim-doc-id", limit: 64
    t.string "claim-reference-number", limit: 32
    t.datetime "created-date"
    t.datetime "submitted-date"
    t.datetime "claim-date"
    t.integer "claim-month"
    t.string "claim-schedule", limit: 16
    t.string "claim-type", limit: 16
    t.integer "claim-year"
    t.boolean "nil-claim"
    t.integer "claim-quarter"
    t.string "claim-status", limit: 32
    t.string "ec-payment-status", limit: 512
    t.date "claim-start-date"
    t.date "claim-end-date"
    t.datetime "claim-submitted-on"
    t.string "claim-submitted-by", limit: 1024
    t.string "claim-submitted-doc-id", limit: 64
    t.datetime "claim-approved-on"
    t.string "claim-approved-by", limit: 1024
    t.string "claim-approved-doc-id", limit: 64
    t.datetime "claim-authorised-on"
    t.string "claim-authorised-by", limit: 1024
    t.string "claim-authorised-doc-id", limit: 64
    t.date "claim-payment-on"
    t.string "claim-payment-by", limit: 1024
    t.string "claim-payment-doc-id", limit: 64
    t.string "certification-status", limit: 64
    t.float "certification-exchange-rate"
    t.date "certification-date"
    t.string "certification-batch-ref", limit: 32
    t.string "certification-batch-doc-id", limit: 64
    t.string "certification-batch-status", limit: 64
    t.date "certification-batch-updated"
    t.integer "intervention-rate"
    t.float "offset-total"
    t.float "offset-capital"
    t.float "offset-revenue"
  end

end
