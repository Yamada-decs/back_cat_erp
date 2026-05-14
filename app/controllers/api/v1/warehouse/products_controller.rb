# app/controllers/api/v1/warehouse/products_controller.rb
module Api
  module V1
    module Warehouse
      class ProductsController < ApplicationController  
        before_action :set_product, only: [:show, :update_stock, :update_price]
        
        # GET /api/v1/warehouse/products
        def index
          @products = filtered_products
            .includes(
              vehicle: { vehicle_model: :vehicle_type },
              spare_part: :spare_part_category
            )
            .order(created_at: :desc)
            .page(params[:page])
            .per(params[:per_page] || 20)
          
          render json: {
            data: @products.map { |p| product_json(p) }, 
            meta: {
              current_page: @products.current_page,
              total_pages: @products.total_pages,
              total_count: @products.total_count
            }
          }
        end
        
        # GET /api/v1/warehouse/products/:id
        def show
          render json: @product.as_json(
            include: {
              vehicle: { only: [:id, :serial, :status, :location, :price_per_hour, :price_per_day] },
              spare_part: { include: [:spare_part_category, :stock_movements] },
              product_images: {}
            }
          )
        end
        
        # PATCH /api/v1/warehouse/products/:id/update_stock
        def update_stock
          if @product.spare_part.present?
            @product.spare_part.update(stock: params[:stock])
            render json: { 
              message: 'Stock actualizado correctamente', 
              stock: @product.spare_part.stock,
              product: @product.name
            }
          else
            render json: { error: 'Solo los repuestos tienen stock' }, 
                   status: :unprocessable_entity
          end
        end
        
        # PATCH /api/v1/warehouse/products/:id/update_price
        def update_price
          if @product.update(base_price: params[:base_price])
            render json: { 
              message: 'Precio actualizado correctamente', 
              base_price: @product.base_price.to_f 
            }
          else
            render json: { errors: @product.errors.full_messages }, 
                   status: :unprocessable_entity
          end
        end
        
        private
        
        def set_product
          @product = Product.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Producto no encontrado' }, status: :not_found
        end
        
        def filtered_products
          products = Product.all
          
          products = products.where(product_type: params[:type]) if params[:type].present?
          products = products.where(active: true) if params[:active] == 'true'
          products = products.where(active: false) if params[:inactive] == 'true'
          products = products.where(code: params[:code]) if params[:code].present?
          products = products.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
          
          if params[:min_price].present?
            products = products.where('base_price >= ?', params[:min_price])
          end
          
          if params[:max_price].present?
            products = products.where('base_price <= ?', params[:max_price])
          end
          
          products
        end
        
        def product_json(product)
          # 👈 DEFINIR json AQUÍ
          json = {
            id: product.id,
            code: product.code,
            name: product.name,
            product_type: product.product_type,
            description: product.description,
            base_price: product.base_price.to_f,
            active: product.active,
            created_at: product.created_at,
            updated_at: product.updated_at
          }

          if product.vehicle?
            json[:vehicle] = {
              serial: product.vehicle&.serial,
              manufacture_year: product.vehicle&.manufacture_year,
              hours_used: product.vehicle&.hours_used,
              status: product.vehicle&.status,
              price_per_hour: product.vehicle&.price_per_hour&.to_f,
              price_per_day: product.vehicle&.price_per_day&.to_f,
              location: product.vehicle&.location,
              vehicle_model_id: product.vehicle&.vehicle_model_id,
              vehicle_model: product.vehicle&.vehicle_model&.model,
              vehicle_brand: product.vehicle&.vehicle_model&.brand,
              vehicle_type_id: product.vehicle&.vehicle_model&.vehicle_type_id,
              vehicle_type: product.vehicle&.vehicle_model&.vehicle_type&.name
            }
          elsif product.spare_part?
            json[:spare_part] = {
              part_number: product.spare_part&.part_number,
              manufacturer_brand: product.spare_part&.manufacturer_brand,
              stock: product.spare_part&.stock || 0,
              min_stock: product.spare_part&.min_stock || 5,
              sale_unit: product.spare_part&.sale_unit,
              is_critical: product.spare_part&.is_critical,
              category: product.spare_part&.spare_part_category&.name
            }
          end

          json
        end
      end
    end
  end
end