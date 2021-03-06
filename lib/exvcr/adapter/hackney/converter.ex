defmodule ExVCR.Adapter.Hackney.Converter do
  @moduledoc """
  Provides helpers to mock :hackney methods.
  """

  use ExVCR.Converter

  defp string_to_response(string) do
    response = Enum.map(string, fn({x, y}) -> {String.to_atom(x), y} end)
    response = struct(ExVCR.Response, response)

    if is_map(response.headers) do
      headers = response.headers |> Map.to_list
      response = %{response | headers: headers}
    end

    response
  end

  defp request_to_string([method, url, headers, body, options]) do
    %ExVCR.Request{
      url: parse_url(url),
      headers: parse_headers(headers),
      method: to_string(method),
      body: parse_request_body(body),
      options: options
    }
  end

  # Client is already replaced by body through ExVCR.Adapter.Hackney adapter.
  defp response_to_string({:ok, status_code, headers, client}) do
    %ExVCR.Response{
      type: "ok",
      status_code: status_code,
      headers: parse_headers(headers),
      body: inspect client
    }
  end

  defp response_to_string({:error, reason}) do
    %ExVCR.Response{
      type: "error",
      body: Atom.to_string(reason)
    }
  end

  defp parse_request_body({:form, body}) do
    :hackney_request.encode_form(body) |> elem(2) |> to_string |> ExVCR.Filter.filter_sensitive_data
  end

  defp parse_request_body(body), do: super(body)
end
