require "zlib"

namespace :db do
  desc "Popula o banco com categorias e produtos de exemplo"
  task populate: :environment do
    colors = [
      [108, 117, 125], # cinza
      [13, 110, 253],  # azul
      [25, 135, 84],   # verde
      [220, 53, 69],   # vermelho
      [253, 126, 20],  # laranja
      [111, 66, 193]   # roxo
    ]

    # Gera um PNG sólido em Ruby puro (sem depender de rede ou de programas externos),
    # só para servir de "foto" de exemplo para os produtos.
    solid_png = ->(width, height, r, g, b) do
      chunk = ->(type, data) { [data.bytesize].pack("N") + type + data + [Zlib.crc32(type + data)].pack("N") }

      signature = "\x89PNG\r\n\x1a\n".b
      ihdr = [width, height, 8, 2, 0, 0, 0].pack("NNCCCCC")
      scanline = "\x00".b + [r, g, b].pack("C3") * width
      idat = Zlib::Deflate.deflate(scanline * height)

      signature + chunk.call("IHDR", ihdr) + chunk.call("IDAT", idat) + chunk.call("IEND", "")
    end

    categories = 5.times.map do
      Category.create!(name: Faker::Commerce.department)
    end

    30.times do
      product = Product.create!(
        name: Faker::Commerce.product_name,
        description: Faker::Lorem.sentence,
        price: Faker::Commerce.price(range: 10.0..500.0),
        category: categories.sample
      )

      r, g, b = colors.sample
      product.image.attach(
        io: StringIO.new(solid_png.call(400, 300, r, g, b)),
        filename: "produto-#{product.id}.png",
        content_type: "image/png"
      )
    end

    puts "Criadas #{Category.count} categorias e #{Product.count} produtos!"
  end
end
