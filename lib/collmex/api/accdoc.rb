class Collmex::Api::Accdoc < Collmex::Api::Line

  def self.specification
    [
      { name: :identifyer       , type: :string    , fix: "ACCDOC"          },
      { name: :company_id       , type: :integer   , default: 1             },
      { name: :business_year    , type: :integer                            },
      { name: :id               , type: :integer                            },
      { name: :accdoc_date      , type: :date                               },
      { name: :accounted_date   , type: :date                               },
      { name: :test             , type: :string                             },
      { name: :position_id      , type: :integer                            },
      { name: :account_id       , type: :integer                            },
      { name: :account_name     , type: :string                             },
      { name: :should_have      , type: :integer                            },
      { name: :amount           , type: :currency                           },
      { name: :customer_id      , type: :integer                            },
      { name: :customer_name    , type: :string                             },
      { name: :provider_id      , type: :integer                            },
      { name: :provider_name    , type: :string                             },
      { name: :asset_id         , type: :integer                            },
      { name: :asset_name       , type: :string                             },
      { name: :canceled_accdoc  , type: :integer                            },
      { name: :cost_unit        , type: :string                             },
      { name: :invoice_id       , type: :string                             },
      { name: :customer_order_id, type: :integer                            },
      { name: :jorney_id        , type: :integer                            },
      { name: :belongs_to_id    , type: :integer                            },
      { name: :belongs_to_year  , type: :integer                            },
      { name: :belongs_to_pos   , type: :integer                            },
    ]
  end
end

