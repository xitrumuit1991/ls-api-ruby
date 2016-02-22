if @result
	json.responsecode	@result[:comfirm_response][:comfirm_result][:responsecode]
	json.tranid			@result[:comfirm_response][:comfirm_result][:tranid]
	json.descriptionvn	@result[:comfirm_response][:comfirm_result][:descriptionvn]
	json.descriptionen	@result[:comfirm_response][:comfirm_result][:descriptionen]
	json.price			number_with_delimiter(@price, delimiter: " ")
	json.coin			number_with_delimiter(@coin, delimiter: " ")
	json.status			@result[:comfirm_response][:comfirm_result][:status]
end