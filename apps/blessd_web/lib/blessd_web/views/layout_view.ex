defmodule BlessdWeb.LayoutView do
  use BlessdWeb, :view

  @gravatar_size 48

  def gravatar_url(user, size \\ @gravatar_size) do
    "https://gravatar.com/avatar/#{gravatar_id(user)}.png?s=#{size}&d=mm"
  end

  defp gravatar_id(nil), do: "no_user"
  defp gravatar_id(%{email: email}), do: Base.encode16(:erlang.md5(email), case: :lower)
end
