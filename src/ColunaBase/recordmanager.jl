
abstract type AbstractNewStorageUnit end

abstract type AbstractNewRecord end


# Interface to implement
function get_id(r::AbstractNewRecord)
    @warn "get_id(::$(typeof(r))) not implemented."
    return nothing
end

"Creates a record of information from the model or a storage unit."
function new_record(::Type{RecordType}, id::Int, model, su::AbstractNewStorageUnit) where {RecordType}
    @warn "new_record(::Type{$RecordType}, ::$(typeof(id)), ::$(typeof(model)), ::$(typeof(su))) not implemented."
    return nothing
end

"Restore information from the model or the storage unit that is recorded in a record."
function restore_from_record!(model, su::AbstractNewStorageUnit, r::AbstractNewRecord)
    @warn "restore_from_record!(::$(typeof(model)), ::$(typeof(su)), ::$(typeof(r))) not implemented."
    return nothing
end

"Returns a storage unit from a given type."
function new_storage_unit(::Type{StorageUnitType}, model) where {StorageUnitType}
    @warn "new_storage_unit(::Type{$StorageUnitType}, model) not implemented."
    return nothing
end

mutable struct NewStorageUnitManager{Model,RecordType<:AbstractNewRecord,StorageUnitType<:AbstractNewStorageUnit}
    model::Model
    storage_unit::StorageUnitType
    active_record_id::Int
    function NewStorageUnitManager(::Type{StorageUnitType}, model::M) where {M,StorageUnitType<:AbstractNewStorageUnit}
        return new{M,record_type(StorageUnitType),StorageUnitType}(
            model, new_storage_unit(StorageUnitType, model), 0
        )
    end
end

# Interface
"Returns the type of record stored in a type of storage unit."
function record_type(::Type{StorageUnitType}) where {StorageUnitType}
    @warn "record_type(::Type{$StorageUnitType}) not implemented."
    return nothing
end

"Returns the type of storage unit that stores a type of record."
function storage_unit_type(::Type{RecordType}) where {RecordType}
    @warn "storage_unit_type(::Type{$RecordType}) not implemented."
    return nothing
end

struct NewStorage{ModelType}
    model::ModelType
    units::Dict{DataType,NewStorageUnitManager}
    NewStorage(model::M) where {M} = new{M}(model, Dict{DataType,NewStorageUnitManager}())
end

function _get_storage_unit_manager!(storage, ::Type{StorageUnitType}) where {StorageUnitType<:AbstractNewStorageUnit}
    storage_unit_manager = get(storage.units, StorageUnitType, nothing)
    if isnothing(storage_unit_manager)
        storage_unit_manager = NewStorageUnitManager(StorageUnitType, storage.model)
        storage.units[StorageUnitType] = storage_unit_manager
    end
    return storage_unit_manager
end

# Creates a new record from the current state of the model and the storage unit.
"""
    create_record(storage, storage_unit_type)

Returns a Record that contains a description of the state of the storage unit at the time 
when the method is called.
"""
function create_record(storage, ::Type{StorageUnitType}) where {StorageUnitType<:AbstractNewStorageUnit}
    storage_unit_manager = _get_storage_unit_manager!(storage, StorageUnitType)
    id = storage_unit_manager.active_record_id += 1
    return new_record(
        record_type(StorageUnitType),
        id,
        storage.model,
        storage_unit_manager.storage_unit
    )
end

"""
    restore_from_record!(storage, record)

Restores the state of the storage unit using the record that was previously generated.
"""
function restore_from_record!(storage, record::RecordType) where {RecordType} 
    storage_unit_manager = _get_storage_unit_manager!(storage, storage_unit_type(RecordType))
    restore_from_record!(storage.model, storage_unit_manager.storage_unit, record)
    return true
end
