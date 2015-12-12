class Merchants::Admin::StoresController < Merchants::Admin::ApplicationController

  def update
    if current_store.update_attributes(store_params)
      redirect_to merchants_root_path
    else
      render :edit
    end
  end

  private

    def store_params
      params.require(:store).permit(:nickname, :qq, :avatar)
    end

end
