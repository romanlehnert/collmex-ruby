class Collmex::Api::Cmxknd < Collmex::Api::Line
  def self.specification
    [
      { name: :identifyer       , type: :string    , fix: "CMXKND"          },
      { name: :customer_id      , type: :integer                            },
      { name: :company_id       , type: :integer   , default: 1             },
      { name: :salutation       , type: :string                             },
      { name: :title            , type: :string                             },
      { name: :firstname        , type: :string                             },
      { name: :lastname         , type: :string                             },
      { name: :company          , type: :string                             },
      { name: :department       , type: :string                             },
      { name: :street           , type: :string                             },
      { name: :zipcode          , type: :string                             },
      { name: :city             , type: :string                             },
      { name: :annotation       , type: :string                             },
      { name: :inactive         , type: :integer                            },
      { name: :country          , type: :string                             },
      { name: :phone            , type: :string                             },
      { name: :fax              , type: :string                             },
      { name: :email            , type: :string                             },
      { name: :account_id       , type: :string                             },
      { name: :blz              , type: :string                             },
      { name: :iban             , type: :string                             },
      { name: :bic              , type: :string                             },
      { name: :bank_name        , type: :string                             },
      { name: :vat_id           , type: :string                             },
      { name: :ust_ldnr         , type: :string                             },
      { name: :payment_condition, type: :integer                            },
      { name: :dscout_group     , type: :integer                            },
      { name: :deliver_conditions, type: :string                            },
      { name: :deliver_conditions_additions, type: :string                  },
      { name: :output_media     , type: :integer                            },
      { name: :account_owner    , type: :string                             },
      { name: :address_group    , type: :integer                            },
      { name: :ebay_member      , type: :string                             },
      { name: :price_group      , type: :integer                            },
      { name: :currency         , type: :string                             },
      { name: :agent            , type: :integer                            },
      { name: :cost_unit        , type: :string                             },
      { name: :due_to           , type: :date                               },
      { name: :delivery_ban     , type: :integer                            },
      { name: :building_servant , type: :integer                            },
      { name: :account_id_at_customer, type: :string                        },
      { name: :output_language  , type: :integer                            },
      { name: :email_cc         , type: :string                             },
      { name: :phone_2          , type: :string                             },
      { name: :sepa_mandate_reference, type: :string                        },
      { name: :sepa_mandate_signature_date, type: :date                     },
      { name: :dunning_block    , type: :integer                            },
    ]
  end
end

