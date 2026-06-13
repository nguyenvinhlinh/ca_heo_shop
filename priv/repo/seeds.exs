# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CaHeoShop.Repo.insert!(%CaHeoShop.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias CaHeoShop.Collections.Collection
alias CaHeoShop.ProductVariants.ProductVariant
alias CaHeoShop.Products.Product
alias CaHeoShop.Products.ProductImage
alias CaHeoShop.Repo

upsert_collection = fn attrs ->
  collection = Repo.get_by(Collection, slug: attrs.slug) || %Collection{}

  collection
  |> Collection.changeset(attrs)
  |> Repo.insert_or_update!()
end

collections = %{
  "3d-printed-products" =>
    upsert_collection.(%{
      slug: "3d-printed-products",
      name_vi: "San pham in 3D",
      name_en: "3D Printed Products",
      description_vi: "Do in 3D tu thiet ke rieng, huu dung cho ban lam viec va nha o.",
      description_en: "Self-designed 3D printed products for desks, homes, and custom use.",
      image_filename: "/images/storefront/category-prints.svg",
      nav_display_order: 0
    }),
  "diy-kits" =>
    upsert_collection.(%{
      slug: "diy-kits",
      name_vi: "Bo kit DIY",
      name_en: "DIY Kits",
      description_vi: "Bo kit dien tu va maker de hoc, lap rap, va thu nghiem.",
      description_en: "Electronics and maker kits for learning, assembly, and experiments.",
      image_filename: "/images/storefront/category-kits.svg",
      nav_display_order: 1
    }),
  "home-accessories" =>
    upsert_collection.(%{
      slug: "home-accessories",
      name_vi: "Phu kien gia dung",
      name_en: "Home Accessories",
      description_vi: "Phu kien nho gon, thuc dung cho khong gian song va lam viec.",
      description_en: "Small practical accessories for home and workspace organization.",
      image_filename: "/images/storefront/product-organizer.svg",
      nav_display_order: 2
    }),
  "hydroponics" =>
    upsert_collection.(%{
      slug: "hydroponics",
      name_vi: "Thuy canh",
      name_en: "Hydroponics",
      description_vi: "Phu kien trong cay, gia do va chi tiet tuy bien cho he thuy canh.",
      description_en: "Plant holders, accessories, and custom parts for hydroponic systems.",
      image_filename: "/images/storefront/category-garden.svg",
      nav_display_order: 3
    }),
  "custom-orders" =>
    upsert_collection.(%{
      slug: "custom-orders",
      name_vi: "Dat hang tuy chinh",
      name_en: "Custom Orders",
      description_vi: "Dat in, sua thiet ke, hoac che tao chi tiet theo nhu cau rieng.",
      description_en: "Custom print, design, and fabrication requests for specific needs.",
      image_filename: "/images/storefront/custom-order.svg",
      nav_display_order: 4
    })
}

upsert_product = fn attrs ->
  product = Repo.get_by(Product, slug: attrs.slug) || %Product{}

  product
  |> Product.changeset(attrs)
  |> Repo.insert_or_update!()
end

products = %{
  "modular-desk-organizer" =>
    upsert_product.(%{
      collection_id: collections["home-accessories"].id,
      slug: "modular-desk-organizer",
      name_vi: "Khay sap xep ban lam viec module",
      name_en: "Modular Desk Organizer",
      description_vi: "Khay module giup sap xep but, dung cu nho va linh kien tren ban lam viec.",
      description_en: "A modular organizer for pens, small tools, and parts on a work desk."
    }),
  "starter-electronics-kit" =>
    upsert_product.(%{
      collection_id: collections["diy-kits"].id,
      slug: "starter-electronics-kit",
      name_vi: "Bo kit dien tu nhap mon",
      name_en: "Starter Electronics Kit",
      description_vi: "Bo linh kien co ban de bat dau hoc mach dien va cam bien.",
      description_en: "A basic component kit for learning circuits and sensors."
    }),
  "custom-plant-holder" =>
    upsert_product.(%{
      collection_id: collections["hydroponics"].id,
      slug: "custom-plant-holder",
      name_vi: "Gia do chau cay tuy chinh",
      name_en: "Custom Plant Holder",
      description_vi: "Gia do cay in 3D co kich thuoc tuy chinh cho chau va ong thuy canh.",
      description_en: "A customizable 3D printed holder for pots and hydroponic tubes."
    }),
  "prototype-print-request" =>
    upsert_product.(%{
      collection_id: collections["custom-orders"].id,
      slug: "prototype-print-request",
      name_vi: "Yeu cau in mau thu",
      name_en: "Prototype Print Request",
      description_vi: "Dich vu in mau thu tu file STL, ban ve, hoac y tuong ban dau.",
      description_en: "Prototype printing from an STL file, drawing, or early product idea."
    }),
  "spare-fastener-pack" =>
    upsert_product.(%{
      collection_id: nil,
      slug: "spare-fastener-pack",
      name_vi: "Bo oc vit du phong",
      name_en: "Spare Fastener Pack",
      description_vi:
        "Bo oc vit va chi tiet thay the du phong dung cho nhieu san pham khac nhau.",
      description_en:
        "A spare pack of fasteners and replacement parts that can be sold on its own."
    })
}

upsert_product_image = fn product, attrs ->
  product_image =
    Repo.get_by(ProductImage, product_id: product.id, filename: attrs.filename) || %ProductImage{}

  product_image
  |> ProductImage.changeset(Map.put(attrs, :product_id, product.id))
  |> Repo.insert_or_update!()
end

upsert_product_image.(products["modular-desk-organizer"], %{
  filename: "/images/storefront/product-organizer.svg",
  display_order: 0,
  has_thumbnail: false
})

upsert_product_image.(products["modular-desk-organizer"], %{
  filename: "/images/storefront/category-prints.svg",
  display_order: 1,
  has_thumbnail: false
})

upsert_product_image.(products["starter-electronics-kit"], %{
  filename: "/images/storefront/product-kit.svg",
  display_order: 0,
  has_thumbnail: false
})

upsert_product_image.(products["starter-electronics-kit"], %{
  filename: "/images/storefront/category-kits.svg",
  display_order: 1,
  has_thumbnail: false
})

upsert_product_image.(products["custom-plant-holder"], %{
  filename: "/images/storefront/product-holder.svg",
  display_order: 0,
  has_thumbnail: false
})

upsert_product_image.(products["custom-plant-holder"], %{
  filename: "/images/storefront/category-garden.svg",
  display_order: 1,
  has_thumbnail: false
})

upsert_product_image.(products["prototype-print-request"], %{
  filename: "/images/storefront/custom-order.svg",
  display_order: 0,
  has_thumbnail: false
})

upsert_product_image.(products["prototype-print-request"], %{
  filename: "/images/storefront/hero-workshop.svg",
  display_order: 1,
  has_thumbnail: false
})

upsert_product_variant = fn product, attrs ->
  product_variant =
    Repo.get_by(ProductVariant, product_id: product.id, variant_name: attrs.variant_name) ||
      %ProductVariant{}

  product_variant
  |> ProductVariant.changeset(Map.put(attrs, :product_id, product.id))
  |> Repo.insert_or_update!()
end

upsert_product_variant.(products["modular-desk-organizer"], %{
  variant_name: "Matte black PLA",
  production_cost: 45_000,
  selling_price: 120_000,
  stock_quantity: 8,
  image_filename: "/images/storefront/product-organizer.svg",
  display_order: 0
})

upsert_product_variant.(products["modular-desk-organizer"], %{
  variant_name: "White PLA",
  production_cost: 45_000,
  selling_price: 120_000,
  stock_quantity: 6,
  image_filename: "/images/storefront/product-organizer.svg",
  display_order: 1
})

upsert_product_variant.(products["modular-desk-organizer"], %{
  variant_name: "Custom color request",
  production_cost: 55_000,
  selling_price: 150_000,
  stock_quantity: 0,
  image_filename: "/images/storefront/category-prints.svg",
  display_order: 2
})

upsert_product_variant.(products["starter-electronics-kit"], %{
  variant_name: "Basic kit",
  production_cost: 95_000,
  selling_price: 180_000,
  stock_quantity: 10,
  image_filename: "/images/storefront/product-kit.svg",
  display_order: 0
})

upsert_product_variant.(products["starter-electronics-kit"], %{
  variant_name: "Kit with sensors",
  production_cost: 145_000,
  selling_price: 260_000,
  stock_quantity: 5,
  image_filename: "/images/storefront/category-kits.svg",
  display_order: 1
})

upsert_product_variant.(products["custom-plant-holder"], %{
  variant_name: "Small cup",
  production_cost: 28_000,
  selling_price: 75_000,
  stock_quantity: 12,
  image_filename: "/images/storefront/product-holder.svg",
  display_order: 0
})

upsert_product_variant.(products["custom-plant-holder"], %{
  variant_name: "Medium cup",
  production_cost: 38_000,
  selling_price: 95_000,
  stock_quantity: 9,
  image_filename: "/images/storefront/product-holder.svg",
  display_order: 1
})

upsert_product_variant.(products["custom-plant-holder"], %{
  variant_name: "Custom diameter",
  production_cost: 50_000,
  selling_price: 140_000,
  stock_quantity: 0,
  image_filename: "/images/storefront/category-garden.svg",
  display_order: 2
})

upsert_product_variant.(products["prototype-print-request"], %{
  variant_name: "Send STL file",
  production_cost: 60_000,
  selling_price: 150_000,
  stock_quantity: 0,
  image_filename: "/images/storefront/custom-order.svg",
  display_order: 0
})

upsert_product_variant.(products["prototype-print-request"], %{
  variant_name: "Design assistance",
  production_cost: 120_000,
  selling_price: 300_000,
  stock_quantity: 0,
  image_filename: "/images/storefront/hero-workshop.svg",
  display_order: 1
})

upsert_product_variant.(products["prototype-print-request"], %{
  variant_name: "Repair part",
  production_cost: 70_000,
  selling_price: 180_000,
  stock_quantity: 0,
  image_filename: "/images/storefront/custom-order.svg",
  display_order: 2
})
