class Acp::BroadcastersController < Acp::ApplicationController
	load_and_authorize_resource
	before_filter :init
	before_action :load_data, only: [:new, :create, :edit, :update]
	before_action :set_data, only: [:show, :basic, :edit, :room, :gifts, :images, :videos, :transactions, :update, :trash, :restore, :destroy, :ajax_change_background]

	helper_method :replaceThumbCrop
	
	def replaceThumbCrop id, thumb
    if id.present? and thumb.present?
      if thumb.include?('Thumb_Crop_.jpg')
        new_thumb = 'Thumb_Crop_'+id.to_s+'.jpg'
        return thumb.gsub(/Thumb_Crop_.jpg/, new_thumb)
      end
      if thumb.include?('Thumb_Crop_.JPG')
        new_thumb = 'Thumb_Crop_'+id.to_s+'.JPG'
        return thumb.gsub(/Thumb_Crop_.JPG/, new_thumb)
      end
      if thumb.include?('Thumb_Crop_.png')
        new_thumb = 'Thumb_Crop_'+id.to_s+'.png'
        return thumb.gsub(/Thumb_Crop_.png/, new_thumb)
      end

      if thumb.include?('Thumb_Poster_.jpg')
        new_thumb = 'Thumb_Poster_'+id.to_s+'.jpg'
        return thumb.gsub(/Thumb_Poster_.jpg/, new_thumb)
      end
      if thumb.include?('Thumb_Poster_.JPG')
        new_thumb = 'Thumb_Poster_'+id.to_s+'.JPG'
        return thumb.gsub(/Thumb_Poster_.JPG/, new_thumb)
      end
      if thumb.include?('Thumb_Poster_.png')
        new_thumb = 'Thumb_Poster_'+id.to_s+'.png'
        return thumb.gsub(/Thumb_Poster_.png/, new_thumb)
      end
      return thumb
    end
    return thumb
  end



	def index
		@data = @model.all.where(deleted: 0).order('id desc')
	end

	def recycle_bin
		@data = @model.all.where(deleted: 1).order('id desc')
	end

	def show
	end

	def new
		@data = @model.new
	end

	def edit
	end

	def basic
		@user = @data.user
		@levels = UserLevel.all
	end

	def room
		if @room = @data.public_room
			@room_types = RoomType.all.order('id desc')
			@room_backgrounds = RoomBackground.all.order('id desc')
		else
			redirect_to({ action: 'index' }, alert: 'Idol này chưa có phòng.')
		end
	end

	def gifts
		if room = @data.public_room
			@gifts = room.gift_logs.order('id desc')
		else
			redirect_to({ action: 'index' }, alert: 'Idol này chưa có phòng.')
		end
	end

	def images
		@images = @data.images.order('id desc')
	end

	def videos
		@videos = @data.videos.order('id desc')
	end

	def transactions
		@gifts = @data.user.gift_logs.order('id desc')
	end

	def create
		if User.find(params[:data][:user_id]).present?
			@data = @model.new(parameters)
			@data.user_id = params[:data][:user_id]
			if @data.save
				User.find(params[:data][:user_id]).update(is_broadcaster: true)
				redirect_to({ action: 'index' }, notice: 'Idol was successfully created.')
			else
				render :new
			end
		else
			redirect_to({ action: 'create' }, alert: 'Tài khoản này không tồn tại.')
		end
	end

	def update
		if @data.update(parameters)
			redirect_to({ action: 'index' }, notice: 'Idol was successfully updated.')
		else
			render :edit
		end
	end

	def trash
		@data.update(deleted: 1)
		redirect_to({ action: 'index' }, notice: 'Idol was successfully move to recycle bin.')
	end

	def restore
		@data.update(deleted: 0)
		redirect_to({ action: 'recycle_bin' }, notice: 'Idol was successfully restored.')
	end

	def destroy
		@data.destroy
		redirect_to({ action: 'recycle_bin' }, notice: 'Idol was successfully destroyed.')
	end

	def trash_m
		@model.where(id: params[:item_id]).update_all(deleted: 1)
    	redirect_to({ action: 'index' }, notice: 'Idols were successfully move to recycle bin.')
	end

	def restore_m
		@model.where(id: params[:item_id]).update_all(deleted: 0)
    	redirect_to({ action: 'recycle_bin' }, notice: 'Idols were successfully restored.')
	end

	def destroy_m
	    @model.destroy(params[:item_id])
	    redirect_to({ action: 'recycle_bin' }, notice: 'Idols were successfully destroyed.')
	  end

	def ajax_change_background
		data_update = (params[:type] == 'default') ? {broadcaster_background_id: nil, room_background_id: params[:bg_id]} : {broadcaster_background_id: params[:bg_id], room_background_id: nil}
		@data.public_room.update(data_update)
		render json: true
	end

	def user_autocomplete
		@users = User.where("name LIKE :query", query: "%#{params[:key]}%")
	end

	private
		def init
			@model = controller_name.classify.constantize
		end

		def load_data
			@users 			= User.all.order('id desc').limit(1)
			@bct_types 	= BctType.all.order('id desc')
			@levels 		= BroadcasterLevel.all
		end

		def set_data
			@data = params[:broadcaster_id].present? ? @model.find(params[:broadcaster_id]) : @model.find(params[:id])
		end
		
		def parameters
			params.require(:data).permit(:fullname, :bct_type_id, :broadcaster_level_id, :broadcaster_exp, :recived_heart, :description)
		end
end