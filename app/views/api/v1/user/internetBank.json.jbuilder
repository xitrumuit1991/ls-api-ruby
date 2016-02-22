if @result
	json.responsecode	@result[:deposit_response][:deposit_result][:responsecode]
	json.tranid			@result[:deposit_response][:deposit_result][:tranid]
	json.descriptionvn	@result[:deposit_response][:deposit_result][:descriptionvn]
	json.descriptionen	@result[:deposit_response][:deposit_result][:descriptionen]
	json.status			@result[:deposit_response][:deposit_result][:status]
	json.url			@result[:deposit_response][:deposit_result][:url]
	json.mac			@result[:deposit_response][:deposit_result][:mac]
	json.xmlns			@result[:deposit_response][:deposit_result][:xmlns]
end
