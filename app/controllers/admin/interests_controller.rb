class Admin::InterestsController < Admin::BaseController
  before_action :set_interest, only: %i[ edit update destroy ]

  def index
    @interests = Interest.all
  end

  def new
    @interest = Interest.new
  end

  def edit
  end

  def create
    @interest = Interest.new(interest_params)
    @interest.resume = Resume.first!

    if @interest.save
      redirect_to admin_interests_path, notice: "Interest was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @interest.update(interest_params)
      redirect_to admin_interests_path, notice: "Interest was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @interest.destroy!

    redirect_to admin_interests_path, status: :see_other, notice: "Interest was successfully destroyed."
  end

private

  def set_interest
    @interest = Interest.find(params.expect(:id))
  end

  def interest_params
    params.expect(interest: [ :name ])
  end
end
