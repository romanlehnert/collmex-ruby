class Collmex::Api::AccdocGet < Collmex::Api::Line
  def self.specification
    [
      { name: :identifyer       , type: :string    , fix: "ACCDOC_GET"     },
      { name: :company_id       , type: :integer   , default: 1             },
      { name: :business_year    , type: :integer                            },
      { name: :id               , type: :integer                            },
      { name: :account_id       , type: :integer                            },
      { name: :cost_unit        , type: :integer                            },
      { name: :customer_id      , type: :integer                            },
      { name: :provider_id      , type: :integer                            },
      { name: :asset_id         , type: :integer                            },
      { name: :invoice_id       , type: :integer                            },
      { name: :jorney_id        , type: :integer                            },
      { name: :text             , type: :string                             },
      { name: :date_start       , type: :date                               },
      { name: :date_end         , type: :date                               },
      { name: :cancellattion    , type: :integer                            },
      { name: :changed_only     , type: :integer                            },
      { name: :system_name      , type: :string                             },
    ]
  end
end


