class OptimizeImageJob < ActiveJob::Base
	queue_as :OptimizeImage
	include KrakenHelper

	def perform(obj, key, url)
		if key == "users"
			user_logger = Logger.new("#{Rails.root}/log/OptimizeUser.log")
			link = uploadDowload("#{url}#{obj.avatar_crop}")
			user_logger.info("User #{obj.id} link: linkUptimize: #{link} \n")
			if link != false
				obj.remote_avatar_crop_url = link
				check = obj.save
				user_logger.info("User #{obj.id} Check: #{check} \n\n")
			end
		elsif key == "rooms"
			room_logger = Logger.new("#{Rails.root}/log/OptimizeRoom.log")
			link = uploadDowload("#{url}#{obj.thumb_crop}")
			room_logger.info("Room #{obj.id} link: linkUptimize: #{link} \n")
			if link != false
				obj.remote_thumb_crop_url = link
				check = obj.save
				room_logger.info("Room #{obj.id} Check: #{check} \n\n")
			end
		elsif key == "bct-image"
			bct_image_logger = Logger.new("#{Rails.root}/log/OptimizeBctImage.log")
			link = uploadDowload("#{url}#{obj.image}")
			bct_image_logger.info("Bct image #{obj.id} link: linkUptimize: #{link} \n")
			if link != false
				obj.remote_image_url = link
				check = obj.save
				bct_image_logger.info("Bct image #{obj.id} Check: #{check} \n\n")
			end
		elsif key == "bct-video"
			bct_video_logger = Logger.new("#{Rails.root}/log/OptimizeBctVideo.log")
			link = uploadDowload("#{url}#{obj.thumb}")
			bct_video_logger.info("Bct video #{obj.id} link: linkUptimize: #{link} \n")
			if link != false
				obj.remote_thumb_url = link
				check = obj.save
				bct_video_logger.info("Bct video #{obj.id} Check: #{check} \n\n")
			end
		elsif key == "bct-bg"
			bct_bg_logger = Logger.new("#{Rails.root}/log/OptimizeBctBg.log")
			link = uploadDowload("#{url}#{obj.image}")
			bct_bg_logger.info("Bct bg #{obj.id} link: linkUptimize: #{link} \n")
			if link != false
				obj.remote_image_url = link
				check = obj.save
				bct_bg_logger.info("Bct bg #{obj.id} Check: #{check} \n\n")
			end
		elsif key == "gift"
			gift_logger = Logger.new("#{Rails.root}/log/OptimizeGift.log")
			link = uploadDowload("#{url}#{obj.image}")
			gift_logger.info("Gift #{obj.id} link: linkUptimize: #{link} \n")
			if link != false
				obj.remote_image_url = link
				check = obj.save
				gift_logger.info("Gift #{obj.id} Check: #{check} \n\n")
			end
		elsif key == "poster"
			poster_logger = Logger.new("#{Rails.root}/log/OptimizePoster.log")
			link = uploadDowload("#{url}#{obj.thumb}")
			poster_logger.info("Poster #{obj.id} link: linkUptimize: #{link} \n")
			if link != false
				obj.remote_thumb_url = link
				check = obj.save
				poster_logger.info("Poster #{obj.id} Check: #{check} \n\n")
			end
		elsif key == "room-action"
			room_action_logger = Logger.new("#{Rails.root}/log/OptimizeRoomAction.log")
			link = uploadDowload("#{url}#{obj.image}")
			room_action_logger.info("Room action #{obj.id} link: linkUptimize: #{link} \n")
			if link != false
				obj.remote_image_url = link
				check = obj.save
				room_action_logger.info("Room action #{obj.id} Check: #{check} \n\n")
			end
		elsif key == "room-bg"
			room_bg_logger = Logger.new("#{Rails.root}/log/OptimizeRoomBg.log")
			link = uploadDowload("#{url}#{obj.image}")
			room_bg_logger.info("Room bg #{obj.id} link: linkUptimize: #{link} \n")
			if link != false
				obj.remote_image_url = link
				check = obj.save
				room_bg_logger.info("Room bg #{obj.id} Check: #{check} \n\n")
			end
		elsif key == "slide"
			slide_logger = Logger.new("#{Rails.root}/log/OptimizeSlide.log")
			link = uploadDowload("#{url}#{obj.banner}")
			slide_logger.info("Slide #{obj.id} link: linkUptimize: #{link} \n")
			if link != false
				obj.remote_banner_url = link
				check = obj.save
				slide_logger.info("Slide #{obj.id} Check: #{check} \n\n")
			end
		elsif key == "vip"
			vip_logger = Logger.new("#{Rails.root}/log/OptimizeVip.log")
			link = uploadDowload("#{url}#{obj.image}")
			vip_logger.info("Vip #{obj.id} link: linkUptimize: #{link} \n")
			if link != false
				obj.remote_image_url = link
				check = obj.save
				vip_logger.info("Vip #{obj.id} Check: #{check} \n\n")
			end
		end
	end
end
