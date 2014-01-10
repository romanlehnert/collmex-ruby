class Collmex::Api::Cmxums < Collmex::Api::Line
  def self.specification
    [
      { name: :_1_identifyer, type: :string, fix: "CMXUMS"}, # 1
      { name: :_2_customer_id, type: :integer},
      { name: :_3_company_id, type: :integer, default: 1},
      { name: :_4_receipt_date, type: :date },
      { name: :_5_receipt_number, type: :string }, # 5
      { name: :_6_net_value_full_tax, type: :currency },
      { name: :_7_tax_value_full_tax, type: :currency },
      { name: :_8_net_value_half_tax, type: :currency },
      { name: :_9_tax_value_half_tax, type: :currency },
      { name: :_10_net_value_inter_eu_trade, type: :currency }, # 10
      { name: :_11_net_value_export, type: :currency },
      { name: :_12_account_revenue_tax_free, type: :integer },
      { name: :_13_value_revenue_tax_free, type: :currency },
      { name: :_14_currency_code, type: :string },
      { name: :_15_contra_account, type: :integer }, # 15
      { name: :_16_receipt_type, type: :integer, default: 0 },
      { name: :_17_receipt_text, type: :string },
      { name: :_18_payment_term, type: :integer },
      { name: :_19_account_full_tax, type: :integer },
      { name: :_20_account_half_tax, type: :integer }, # 20
      { name: :_21_reserved21, type: :string },
      { name: :_22_reserved22, type: :string },
      { name: :_23_storno, type: :integer },
      { name: :_24_final_receipt, type: :string },
      { name: :_25_revenue_type, type: :integer }, # 25
      { name: :_26_system_name, type: :string },
      { name: :_27_charge_against_receipt_number, type: :string },
      { name: :_28_cost_center, type: :string }
    ]
  end
end


