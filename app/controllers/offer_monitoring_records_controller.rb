class OfferMonitoringRecordsController < InheritedResources::Base
  layout 'no_sidebar'
  respond_to :html, :xml, :json, :js
  protected
  def resource
    @offer_monitoring_record ||= OfferMonitoringRecord.find(params[:id])
  end

  def collection
    @search = OfferMonitoringRecord.search(params[:search])
    @offer_monitoring_records ||= @search.page(params[:page]).per(30)
  end
end
