class PagesController < ApplicationController
  def signup
    @interview = Interview.new
    render layout: false
  end
end
