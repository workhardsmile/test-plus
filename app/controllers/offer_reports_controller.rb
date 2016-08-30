class OfferReportsController < InheritedResources::Base
  layout 'no_sidebar'

  respond_to :html, :xml, :json, :js

  protected
  def resource
    @offer_report ||= OfferReport.find(params[:id])
  end

  def collection
    @search = OfferReport.search(params[:search])
    @offer_reports ||= @search.order('test_round_id DESC').page(params[:page]).per(30)
  end

end
