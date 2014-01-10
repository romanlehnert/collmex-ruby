class Collmex::Api::Cmxums < Collmex::Api::Line
  def self.specification
    [
      { name: :identifyer, type: :string, fix: "CMXUMS"}, # 1
      { name: :customer_id, type: :integer},
      { name: :company_id, type: :integer, default: 1},
      { name: :receipt_date, type: :date },
      { name: :receipt_number, type: :string }, # 5
      { name: :net_value_full_tax, type: :currency },
      { name: :tax_value_full_tax, type: :currency },
      { name: :net_value_half_tax, type: :currency },
      { name: :tax_value_half_tax, type: :currency },
      { name: :net_value_inter_eu_trade, type: :currency }, # 10
      { name: :net_value_export, type: :currency },
      { name: :account_revenue_tax_free, type: :integer },
      { name: :value_revenue_tax_free, type: :currency },
      { name: :currency_code, type: :string },
      { name: :contra_account, type: :integer }, # 15
      { name: :receipt_type, type: :integer, default: 0 },
      { name: :receipt_text, type: :string },
      { name: :payment_term, type: :integer },
      { name: :account_full_tax, type: :integer },
      { name: :account_half_tax, type: :integer }, # 20
      { name: :reserved21, type: :string },
      { name: :reserved22, type: :string },
      { name: :storno, type: :integer },
      { name: :final_receipt, type: :string },
      { name: :revenue_type, type: :integer }, # 25
      { name: :system_name, type: :string },
      { name: :charge_against_receipt_number, type: :string },
      { name: :cost_center, type: :string }
    ]
  end
end


