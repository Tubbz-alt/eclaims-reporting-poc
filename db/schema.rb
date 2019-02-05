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
    t.string "claim_doc_id", limit: 64
    t.string "claim_reference_number", limit: 32
    t.string "pa_name", limit: 8
    t.string "ip_name", limit: 1024
    t.string "ip_code", limit: 8
    t.string "type", limit: 32
    t.float "fund"
    t.float "public"
    t.float "fric_cap"
    t.float "fric_rev"
    t.float "frpp_cap"
    t.float "frpp_rev"
    t.float "fund_cap_intervention_rate"
    t.float "fund_rev_intervention_rate"
    t.float "fund_tot_intervention_rate"
    t.float "public_cap_intervention_rate"
    t.float "public_rev_intervention_rate"
    t.float "public_tot_intervention_rate"
    t.float "private_cap_intervention_rate"
    t.float "private_rev_intervention_rate"
    t.float "private_tot_intervention_rate"
    t.float "eligible_cap_expenditure"
    t.float "eligible_rev_expenditure"
    t.float "total_cap_expenditure"
    t.float "total_rev_expenditure"
    t.float "fund_cap_expenditure"
    t.float "fund_rev_expenditure"
    t.float "public_cap_expenditure"
    t.float "public_rev_expenditure"
    t.float "private_cap_expenditure"
    t.float "private_rev_expenditure"
  end

  create_table "claims", id: false, force: :cascade do |t|
    t.string "claim_doc_id", limit: 64
    t.string "claim_reference_number", limit: 32
    t.datetime "created_date"
    t.datetime "submitted_date"
    t.datetime "claim_date"
    t.integer "claim_month"
    t.string "claim_schedule", limit: 16
    t.string "claim_type", limit: 16
    t.integer "claim_year"
    t.boolean "nil_claim"
    t.integer "claim_quarter"
    t.string "claim_status", limit: 32
    t.string "ec_payment_status", limit: 512
    t.date "claim_start_date"
    t.date "claim_end_date"
    t.datetime "claim_submitted_on"
    t.string "claim_submitted_by", limit: 1024
    t.string "claim_submitted_doc_id", limit: 64
    t.datetime "claim_approved_on"
    t.string "claim_approved_by", limit: 1024
    t.string "claim_approved_doc_id", limit: 64
    t.datetime "claim_authorised_on"
    t.string "claim_authorised_by", limit: 1024
    t.string "claim_authorised_doc_id", limit: 64
    t.date "claim_payment_on"
    t.string "claim_payment_by", limit: 1024
    t.string "claim_payment_doc_id", limit: 64
    t.string "certification_status", limit: 64
    t.float "certification_exchange_rate"
    t.date "certification_date"
    t.string "certification_batch_ref", limit: 32
    t.string "certification_batch_doc_id", limit: 64
    t.string "certification_batch_status", limit: 64
    t.date "certification_batch_updated"
    t.integer "intervention_rate"
    t.float "offset_total"
    t.float "offset_capital"
    t.float "offset_revenue"
  end

end
