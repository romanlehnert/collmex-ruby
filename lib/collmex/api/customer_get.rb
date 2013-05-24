class Collmex::Api::CustomerGet < Collmex::Api::Line
  def self.specification
    [
      { name: :identifyer       , type: :string    , fix: "CUSTOMER_GET"    },
      { name: :id               , type: :integer                            },
      { name: :company_id       , type: :integer   , default: 1             },
      { name: :searchtext       , type: :string                             },
      { name: :due_to_review    , type: :integer                            },
      { name: :zip_code         , type: :string                             },
      { name: :adress_group     , type: :integer                            },
      { name: :price_group      , type: :integer                            },
      { name: :discout_group    , type: :integer                            },
      { name: :agent            , type: :integer                            },
      { name: :only_changed     , type: :integer                            },
      { name: :system_name      , type: :string                             },
      { name: :inactive         , type: :integer                            },
    ]
  end
end
