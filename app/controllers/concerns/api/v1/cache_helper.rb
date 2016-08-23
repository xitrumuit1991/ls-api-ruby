module Api::V1::CacheHelper extend ActiveSupport::Concern
	def fetch_vip weight
		vip = $redis.get "vip:#{weight}"
		if vip.nil?
			vip = Vip.find_by_weight(weight).to_json
			$redis.set "vip:#{weight}", vip
		end
		JSON.load vip
	end

	def fetch_action id
		action = $redis.get "action:#{id}"
		if action.nil?
			action = RoomAction.find_by_id(id).to_json
			$redis.set "action:#{id}", action
		end
		JSON.load action
	end

	def fetch_gift id
		gift = $redis.get "gift:#{id}"
		if gift.nil?
			gift = Gift.find_by_id(id).to_json
			$redis.set "gift:#{id}", gift
		end
		JSON.load gift
	end

	def clear_action
		RoomAction.all.each do |action|
			$redis.set "action:#{action.id}", action.to_json
		end
	end

	def clear_gift
		Gift.all.each do |gift|
			$redis.set "gift:#{gift.id}", gift.to_json
		end
	end
end