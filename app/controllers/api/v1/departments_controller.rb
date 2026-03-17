module Api
  module V1
    class DepartmentsController < BaseController
      before_action :set_department, only: [:show, :update]

      def index
        departments = Department.all.order(:code)
        render json: DepartmentSerializer.new(departments).serializable_hash
      end

      def show
        authorize @department
        render json: DepartmentSerializer.new(@department).serializable_hash
      end

      def create
        department = Department.new(department_params)
        authorize department
        if department.save
          render json: DepartmentSerializer.new(department).serializable_hash,
                 status: :created
        else
          render json: { errors: department.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @department
        if @department.update(department_params)
          render json: DepartmentSerializer.new(@department).serializable_hash
        else
          render json: { errors: @department.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_department
        @department = Department.find(params[:id])
      end

      def department_params
        params.require(:department).permit(:name, :code)
      end
    end
  end
end