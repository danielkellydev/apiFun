module PagesHelper
    def map_field_id_to_name(id)
        {
          1 => "Subjective",
          2 => "Objective",
          3 => "Treatment",
          4 => "Plan"
        }[id]
      end
end
