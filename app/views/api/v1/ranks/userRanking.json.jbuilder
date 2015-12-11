if @user.is_broadcaster
	json.received_hearts do
		json.rank	@received_hearts
		json.total	@total_hearts
	end
	json.received_gifts do
		json.rank 	@received_gifts
		json.total 	@total_money
	end
else
	json.send_gifts do
		json.rank 	@send_gifts
		json.total 	@total_money
	end
end

json.level_ups do
	json.rank 	@level_ups
	json.times 	@times
end