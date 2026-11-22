import mysql.connector
from mysql.connector import Error


def main():
    connection = mysql.connector.connect(
        host="localhost",
        user="root",
        password="YOUR_PASSWORD",
        database="DBPROJECT",
    )
    cursor = connection.cursor()

    lab_name = "Physics Laboratory"
    cursor.execute(
        "SELECT U.serialNo, M.commercialName "
        "FROM EquipmentUnit U "
        "JOIN EquipmentModel M ON M.modelId = U.modelId "
        "JOIN Laboratory L ON L.labId = U.labId "
        "WHERE L.name = %s AND U.status = 'InService'",
        (lab_name,),
    )
    print("In-service equipment in", lab_name)
    for serial_no, model_name in cursor.fetchall():
        print(serial_no, model_name)

    cursor.execute(
        "SELECT labName, consumableName, quantityOnHand "
        "FROM LaboratoryStockSummary WHERE stockLevel = %s",
        ("LOW",),
    )
    print("Low stock")
    for lab, consumable, quantity in cursor.fetchall():
        print(lab, consumable, quantity)

    routine_values = cursor.callproc("RestockLab", [1, 1, 5.00, 0])
    for result in cursor.stored_results():
        result.fetchall()
    print("Quantity after restock:", routine_values[3])

    try:
        cursor.execute("INSERT INTO Reserves VALUES (%s, %s)", (1, "U3"))
        connection.commit()
    except Error as error:
        print("Database rejected reservation:", error.msg)
        connection.rollback()

    cursor.close()
    connection.close()


if __name__ == "__main__":
    main()
