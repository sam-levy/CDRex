defmodule CDRex.Factories.FileHashFactory do
  defmacro __using__(_opts \\ []) do
    quote do
      alias CDRex.FileHashes.FileHash

      def factory(:file_hash, attrs) do
        %FileHash{
          hash: build_hash("File Content")
        }
      end

      def build_hash(string) do
        :crypto.hash(:sha256, string)
        |> Base.encode16()
        |> String.downcase()
      end
    end
  end
end
