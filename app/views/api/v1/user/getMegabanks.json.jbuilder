json.array! @megabanks do |megabank1|
	json.id				megabank1.id
	json.price			number_with_delimiter(megabank1.price, delimiter: ".")
	json.coin			number_with_delimiter(megabank1.coin, delimiter: ".")
end