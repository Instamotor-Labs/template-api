module ParamsHelper
  def permitted_params
    @permitted_params ||= Hashie::Mash.new(declared(params, include_missing: false))
  end
end