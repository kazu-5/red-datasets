require "csv"

require_relative "dataset"

module Datasets
  class Hepatitis < Dataset
    Record = Struct.new(
      :label,
      :age,
      :sex,
      :steroid,
      :antivirals,
      :fatigue,
      :malaise,
      :anorexia,
      :liver_big,
      :liver_firm,
      :spleen_palpable,
      :spiders,
      :ascites,
      :varices,
      :bilirubin,
      :alk_phosphate,
      :sgot,
      :albumin,
      :protime,
      :histology
    )

    def initialize
      super()
      @metadata.id = "hepatitis"
      @metadata.name = "Hepatitis"
      @metadata.url = "https://archive.ics.uci.edu/ml/datasets/hepatitis"
      @metadata.description = lambda do
        read_names
      end
    end

    def each
      return to_enum(__method__) unless block_given?

      open_data do |csv|
        csv.each do |row|
          next if row[0].nil?
          record = Record.new(*row)
          yield(record)
        end
      end
    end

    private
    def open_data
      data_path = cache_dir_path + "hepatitis.csv"
      unless data_path.exist?
        data_url = "https://archive.ics.uci.edu/ml/machine-learning-databases/hepatitis/hepatitis.data"
        download(data_path, data_url)
      end
      CSV.open(data_path,
               {
                 converters: [:numeric, lambda {|f| f.strip}],
                 skip_lines: /\A\|/,
               }) do |csv|
        yield(csv)
      end
    end

    def read_names
      names_path = cache_dir_path + "hepatitis.names"
      unless names_path.exist?
        names_url = "https://archive.ics.uci.edu/ml/machine-learning-databases/hepatitis/hepatitis.names"
        download(names_path, names_url)
      end
      names_path.read
    end
  end
end
