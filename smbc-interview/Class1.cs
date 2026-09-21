using System.Xml;
using System.Xml.Linq;

// namespace smbc;

// public record Employees(string EmployeeId, string Firstname, string LastName, string Department,
//     string Email, DateTime HireDate, string Salary);

class Program
{
    static void Main(string[] args)
    {
        if (args.Length < 2)
        {
            Console.WriteLine("need xml and csv paths in command line");
            return;
        }

        string inputPath = args[0];
        string outputPath = args[1];

        XDocument doc;
        try
        {
            doc = XDocument.Load(inputPath);
        }
        catch(XmlException ex)
        {
            Console.WriteLine("xml file bad");
            return;
        }
        catch(FileNotFoundException ex)
        {
            Console.WriteLine("xml file not found");
            return;
        }

        using (StreamWriter writer = new StreamWriter(outputPath))
        {
            writer.WriteLine("EmployeeId,FirstName,LastName,Department,Email,HireDate,Salary");

            if (doc.Root is null)
            {
                Console.WriteLine("doc empty");
                return;
            }

            foreach(XElement emp in doc.Root.Elements("Employee"))
            {
                string employeeId = emp.Element("EmployeeId")?.Value ?? "";
                string firstName = emp.Element("FirstName")?.Value ?? "";
                string lastName = emp.Element("LastName")?.Value ?? "";
                string department = emp.Element("Department")?.Value ?? "";
                string email = emp.Element("Email")?.Value ?? "";
                string hireDate = emp.Element("HireDate")?.Value ?? "";
                string salary = emp.Element("Salary")?.Value ?? "";

                writer.WriteLine($"{employeeId},{firstName},{lastName},{department},{email},{hireDate},{salary}");
            }
        }

        Console.Write($"conerted {inputPath} to {outputPath}");
    }
}