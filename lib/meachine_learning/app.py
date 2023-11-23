from flask import Flask, request, jsonify
from flask_cors import CORS
from dna_matching import calculate_matching_percentage  # Import the function
import json

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes
port = 5000

# ... (other code)


import mysql.connector

# Database configuration
db_config = {
    "host": "192.168.41.180",
    "user": "root",
    "password": "93420D@l",
    "database": "organ_donation",
    "port": 3306,
}


def fetch_organ_details_from_database(organ_name):
    try:
        # Establish a connection to the database
        connection = mysql.connector.connect(**db_config)
        cursor = connection.cursor()

        # Fetch organ details based on organ_name from the organ table
        query = "SELECT * FROM organ WHERE organ_name = %s"
        cursor.execute(query, (organ_name,))
        organ_details = cursor.fetchone()

        return organ_details

    except mysql.connector.Error as err:
        print(f"Error: {err}")
        # Handle the database error as needed

    finally:
        # Close the cursor and connection
        if cursor:
            cursor.close()
        if connection.is_connected():
            connection.close()


# Placeholder functions for compatibility checks (replace these with your actual logic)
def check_blood_compatibility(organ_blood_group, recipient_blood_group):
    # ABO Blood Group System
    abo_groups = {
        "A": ["A", "AB"],
        "B": ["B", "AB"],
        "AB": ["AB"],
        "O": ["A", "B", "AB", "O"],
    }

    # Rh(D) Blood Group System
    rh_groups = {"+": ["+", "-"], "-": ["-"]}

    organ_abo, organ_rh = organ_blood_group.split("+")  # Extract ABO and Rh(D) groups
    recipient_abo, recipient_rh = recipient_blood_group.split(
        "+"
    )  # Extract ABO and Rh(D) groups

    # Check ABO compatibility
    if recipient_abo in abo_groups[organ_abo] and recipient_rh in rh_groups[organ_rh]:
        return True
    else:
        return False


def check_antibody_screening(antibody_screening):
    # Implement antibody screening compatibility check logic here
    # Assuming antibody_screening can be 'low', 'medium', or 'high'
    # Return True if compatible (low or medium), False otherwise
    return antibody_screening in ["low", "medium"]


def check_hiv_status(hiv_status):
    # Implement HIV status compatibility check logic here
    # Assuming hiv_status can be 'positive' or 'negative'
    # Return True if compatible (negative), False otherwise
    return hiv_status == "negative"


def check_hepatitis_b_status(hepatitis_b_status):
    # Implement Hepatitis B status compatibility check logic here
    # Assuming hepatitis_b_status can be 'positive' or 'negative'
    # Return True if compatible (negative), False otherwise
    return hepatitis_b_status == "negative"


def check_hepatitis_c_status(hepatitis_c_status):
    # Implement Hepatitis C status compatibility check logic here
    # Assuming hepatitis_c_status can be 'positive' or 'negative'
    # Return True if compatible (negative), False otherwise
    return hepatitis_c_status == "negative"


def check_age_difference(recipient_age, organ_donor_age):
    # Implement age difference compatibility check logic here
    # Assuming recipient_age and organ_donor_age are integers representing ages
    if recipient_age < 10:
        # If recipient age is below 10, the age difference must be 5 years
        return abs(recipient_age - organ_donor_age) <= 5
    elif 10 <= recipient_age <= 25:
        # If recipient age is between 10 and 25, the age difference must be below 10 years
        return abs(recipient_age - organ_donor_age) < 10
    else:
        # If recipient age is above 25, the age difference must be below 20 years
        return abs(recipient_age - organ_donor_age) < 20


# Flask route for checking organ availability and compatibility
# Flask route for checking organ availability and compatibility
@app.route("/check_organ_availability", methods=["POST"])
def check_organ_availability():
    data = request.get_json()
    organ_name = data.get("organ_name")

    # Fetch organ details from the database based on organ_name
    organ_details = fetch_organ_details_from_database(organ_name)

    if organ_details:
        organ_blood_group = organ_details[
            "blood_group"
        ]  # Fetch organ's blood group from organ_details
        recipient_blood_group = data.get(
            "blood_group"
        )  # Fetch recipient's blood group from the request data
        antibody_screening = data.get("antibody_screening")
        hiv_status = data.get("hiv_status")
        hepatitis_b_status = data.get("hepatitis_b_status")
        hepatitis_c_status = data.get("hepatitis_c_status")
        age = data.get("age")

        # Perform compatibility checks
        if (
            check_blood_compatibility(organ_blood_group, recipient_blood_group)
            and check_antibody_screening(antibody_screening)
            and check_hiv_status(hiv_status)
            and check_hepatitis_b_status(hepatitis_b_status)
            and check_hepatitis_c_status(hepatitis_c_status)
            and check_age_difference(
                age, organ_details["oage"]
            )  # Pass donor's age from organ_details
        ):
            return jsonify({"message": "Organ is available and compatible"}), 200
        else:
            return jsonify({"message": "Organ is not available or not compatible"}), 400
    else:
        return jsonify({"message": "Organ is not available"}), 400


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=port)
