module Defs
  extend ::Trax::Core::Definitions

  enum :Category do
    define :default,     1
    define :clothing,    2
    define :shoes,       3
    define :accessories, 4
  end

  struct :ProductAttributes do
    string :name, :default => ""
    float :price, :default => 9.99
    integer :quantity_in_stock, :default => 0
    boolean :is_active, :default => false
    array :categories, :of => "Defs::Category", :default => []
  end

  struct :ShoesAttributes, :extend => "Defs::ProductAttributes" do
    enum :size do
      define :mens_8,  1
      define :mens_9,  2
      define :mens_10, 3
      define :mens_11, 4
      define :mens_12, 5
    end
  end
end
