json.array! @banks do |bank|
	json.id				bank.id
	json.bankID			bank.bankID
	json.name			bank.name
	json.status			bank.status
end