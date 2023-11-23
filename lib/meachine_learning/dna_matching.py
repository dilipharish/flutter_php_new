def calculate_matching_percentage(dna1, dna2):
    max_percentage = 0
    current_percentage = 0
    max_start = 0
    max_end = 0
    current_start = 0

    for i in range(min(len(dna1), len(dna2))):
        if (
            (dna1[i] == "A" and dna2[i] == "T")
            or (dna1[i] == "T" and dna2[i] == "A")
            or (dna1[i] == "G" and dna2[i] == "C")
            or (dna1[i] == "C" and dna2[i] == "G")
        ):
            current_percentage += 1
            if current_percentage == 1:
                current_start = i
            current_end = i
        else:
            if current_percentage > max_percentage:
                max_percentage = current_percentage
                max_start = current_start
                max_end = current_end
            current_percentage = 0

    # Check the last pair
    if current_percentage > max_percentage:
        max_percentage = current_percentage
        max_start = current_start
        max_end = current_end

    total_pairs = min(len(dna1), len(dna2))
    matching_percentage = (max_percentage / total_pairs) * 100

    return matching_percentage, max_start, max_end
