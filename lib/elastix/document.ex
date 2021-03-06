defmodule Elastix.Document do
  @moduledoc """
  """
  import Elastix.HTTP, only: [prepare_url: 2]
  alias Elastix.{HTTP, JSON}

  @doc false
  def index(elastic_url, index_name, type_name, id, data) do
    index(elastic_url, index_name, type_name, id, data, [])
  end

  @doc false
  def index(elastic_url, index_name, type_name, id, data, query_params) do
    prepare_url(elastic_url, make_path(index_name, type_name, query_params, id))
    |> HTTP.put(JSON.encode!(data))
  end

  @doc false
  def index_new(elastic_url, index_name, type_name, data) do
    index_new(elastic_url, index_name, type_name, data, [])
  end

  @doc false
  def index_new(elastic_url, index_name, type_name, data, query_params) do
    prepare_url(elastic_url, make_path(index_name, type_name, query_params))
    |> HTTP.post(JSON.encode!(data))
  end

  @doc false
  def get(elastic_url, index_name, type_name, id) do
    get(elastic_url, index_name, type_name, id, [])
  end

  @doc false
  def get(elastic_url, index_name, type_name, id, query_params) do
    prepare_url(elastic_url, make_path(index_name, type_name, query_params, id))
    |> HTTP.get
  end

  @doc """
  Get multiple documents matching the query using the Multi Get API.
  """
  def mget(elastic_url, query, index_name \\ nil, type_name \\ nil, query_params \\ []) do
    path = [index_name, type_name]
      |> Enum.filter(fn v -> v end) # Filter out nils.
      |> Enum.join("/")
    url = prepare_url(elastic_url, [path, "_mget"])
      |> add_query_params(query_params)

    # HTTPoison does not provide an API for a GET request with a body.
    HTTP.request(:get, url, JSON.encode!(query))
  end

  @doc false
  def delete(elastic_url, index_name, type_name, id, query_params \\ []) do
    prepare_url(elastic_url, make_path(index_name, type_name, query_params, id))
    |> HTTP.delete
  end

  @doc """
  Uses the Delete By Query API.
  """
  def delete_matching(elastic_url, index_name, %{}=query, query_params \\ []) do
    prepare_url(elastic_url, [index_name, "_delete_by_query"])
    |> add_query_params(query_params)
    |> HTTP.post(JSON.encode!(query))
  end

  @doc false
  def update(elastic_url, index_name, type_name, id, data, query_params \\ []) do
    elastic_url
    |> prepare_url(make_path(index_name, type_name, query_params, id, "_update"))
    |> HTTP.post(JSON.encode!(data))
  end

  @doc false
  def make_path(index_name, type_name, query_params) do
    "/#{index_name}/#{type_name}"
    |> add_query_params(query_params)
  end
  def make_path(index_name, type_name, query_params, id, suffix \\ nil) do
    "/#{index_name}/#{type_name}/#{id}/#{suffix}"
    |> add_query_params(query_params)
  end

  @doc false
  defp add_query_params(path, []), do: path
  defp add_query_params(path, query_params) do
    query_string = Enum.map_join query_params, "&", fn(param) ->
      "#{elem(param, 0)}=#{elem(param, 1)}"
    end

    "#{path}?#{query_string}"
  end
end
