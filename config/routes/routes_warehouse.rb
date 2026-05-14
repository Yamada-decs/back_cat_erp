Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :warehouse do
        
        # Ver productos
        get '/products', to: 'products#index'
        get '/products/:id', to: 'products#show', constraints: { id: /[0-9a-fA-F\-]{36}/ }
        
        # Editar productos
        patch '/products/:id/update_stock', to: 'products#update_stock'
        patch '/products/:id/update_price', to: 'products#update_price'
        
        # Reportes y búsquedas
        get '/products/search', to: 'products#search'
        get '/products/low_stock', to: 'products#low_stock'
        get '/products/critical_stock', to: 'products#critical_stock'

          ####################### Órdenes de Compra ##############################
        get    '/purchase_orders',                   to: 'purchase_orders#index'
        get    '/purchase_orders/select',            to: 'purchase_orders#index_select'
        get    '/purchase_orders/:id',               to: 'purchase_orders#show', constraints: { id: /[0-9a-fA-F\-]{36}/ }
        post   '/purchase_orders',                   to: 'purchase_orders#create'
        put    '/purchase_orders/:id',               to: 'purchase_orders#update'
        patch  '/purchase_orders/:id',               to: 'purchase_orders#update'
        delete '/purchase_orders/:id',               to: 'purchase_orders#destroy'
        put    '/purchase_orders/:id/receive',       to: 'purchase_orders#receive'
        put    '/purchase_orders/:id/cancel',        to: 'purchase_orders#cancel' 
        get    '/purchase_orders/by_supplier/:supplier_id', to: 'purchase_orders#by_supplier'
        
      end
    end
  end
end