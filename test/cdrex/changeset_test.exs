defmodule CDRex.ChangesetTest do
  use CDRex.DataCase, async: true

  describe "add_timestamps/1" do
    test "adds timestmaps" do
      assert %{inserted_at: %DateTime{}, updated_at: %DateTime{}} =
               CDRex.Changeset.add_timestamps(%{})
    end
  end
end
