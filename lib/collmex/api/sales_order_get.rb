class Collmex::Api::SalesOrderGet < Collmex::Api::Line
  def self.specification
    [
      {name: :identifyer,             type: :string, fix: "SALES_ORDER_GET"},
      {name: :order_id,               type: :string},
      {name: :company_id,             type: :integer},
      {name: :customer_id,            type: :integer},
      {name: :date_from,              type: :date},
      {name: :date_to,                type: :date},
      {name: :order_id_for_customer,  type: :string},
      {name: :format,                 type: :string}, # 1 means ZIP file with PDF
      {name: :changed_only,           type: :integer},
      {name: :system_name,            type: :string},
      {name: :created_by_system_only, type: :integer}, # 1 means take only records created by the "system_name"
      {name: :without_stationary,     type: :integer}
    ]
  end
end


