json.array! @providers do |provider|
	json.id				provider.id
	json.name			provider.name
	json.slug			provider.slug
	json.description	provider.description
end