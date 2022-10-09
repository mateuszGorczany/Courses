using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ConsoleApplication2
{
    class ModelParam
    {
        public int Id { get; set; }
        public String fuelType { get; set; }
        public Int32 enginePower { get; set; }
        public Int32 engineTorque { get; set; }
    }

    class Model
    {
        public int Id
        {
            get { return rId; }
            set { rId = value; }
        }
        public String name { get; set; }
        public Int32 refMarka { get; set; }
        public List<ModelParam> prop { get; set; }
        private int rId;
    }

    class Samochod 
    {
        public int ID { get; set; }
        public int IDMarka { get; set; }
        public int IDNadwozie { get; set; }
        public String Kolor { get; set; }
        public int pojemnoscSilnik { get; set; }
    }

    class Marka 
    {
        public int ID { get; set; }
        public String Nazwa { get; set; }
    }

    class Nadwozie
    {
        public int ID { get; set; }
        public String Nazwa { get; set; }
    }


    class Program
    {
        static void Main(string[] args)
        {
            List<Samochod> samochody = new List<Samochod> {
                new Samochod{ID = 1,IDMarka = 1,IDNadwozie = 1,Kolor = "Czarny",pojemnoscSilnik =1600},
                new Samochod{ID = 2,IDMarka = 2,IDNadwozie = 2,Kolor = "Niebieski",pojemnoscSilnik=2000},
                new Samochod{ID = 3,IDMarka = 3,IDNadwozie = 3,Kolor = "Czarny",pojemnoscSilnik =2000},
                new Samochod{ID = 4,IDMarka = 4,IDNadwozie = 1,Kolor = "Czarny",pojemnoscSilnik =1600},
                new Samochod{ID = 5,IDMarka = 5,IDNadwozie = 2,Kolor = "Niebieski",pojemnoscSilnik=1600},
                new Samochod{ID = 5,IDMarka = 5,IDNadwozie = 3,Kolor = "Czerwony",pojemnoscSilnik =2000}
            };

            List<Nadwozie> nadwozie = new List<Nadwozie>{
                new Nadwozie { ID = 1, Nazwa="sedan"},
                new Nadwozie { ID = 2, Nazwa="hatchback"},
                new Nadwozie { ID = 3, Nazwa="SUV"}
            };

            List<Marka> marki = new List<Marka>
            {
                new Marka { ID = 1, Nazwa = "Fiat"},
                new Marka { ID = 2, Nazwa = "BMW"},
                new Marka { ID = 3, Nazwa = "Peugot"},
                new Marka { ID = 4, Nazwa = "Volkswagen"},
                new Marka { ID = 5, Nazwa = "Toyota"},
                new Marka { ID = 6, Nazwa = "Mazda"},
                new Marka { ID = 7, Nazwa = "Seat"}
            };

            // Model info

            ModelParam par1 = new ModelParam()
            {
                Id = 1,
                fuelType = "Petrol",
                enginePower = 110,
                engineTorque = 130
            };

            ModelParam par2 = new ModelParam()
            {
                Id = 2,
                fuelType = "Petrol",
                enginePower = 170,
                engineTorque = 290
            };

            ModelParam par3 = new ModelParam()
            {
                Id = 3,
                fuelType = "Diesel",
                enginePower = 140,
                engineTorque = 280
            };

            ModelParam par4 = new ModelParam()
            {
                Id = 4,
                fuelType = "Diesel",
                enginePower = 190,
                engineTorque = 320
            };

            List<Model> models = new List<Model> {
                new Model { Id = 1, name = "CX5", refMarka = 6, prop = new List<ModelParam> {par1, par3} },
                new Model { Id = 2, name = "Corolla", refMarka = 5, prop = new List<ModelParam> {par2, par3} },
                new Model { Id = 3, name = "Leon", refMarka = 7, prop = new List<ModelParam> {par2, par4} },
                new Model { Id = 4, name = "M1", refMarka = 1, prop = new List<ModelParam> {par1, par3} },
                new Model { Id = 5, name = "M2", refMarka = 2, prop = new List<ModelParam> {par2, par2} },
                new Model { Id = 6, name = "M3", refMarka = 3, prop ew List<ModelParam> {par1, par3} },
                new Model { Id = 7, name = "M4", refMarka = 4, prop = new List<ModelParam> {par3, par4} }
            };
 
            Console.WriteLine("zad1\n");

            var query1 = from marka in marki
                         join model in models on marka.ID equals model.refMarka
                         select new { marka.Nazwa, model.name, model.prop };

            foreach (var q2 in query1)
            {
                foreach (var q3 in q2.prop)
                {
                    Console.WriteLine("{0}:{1}:{2}", q2.Nazwa, q3.engineTorque, q3.fuelType);
                }
               
            }

            Console.WriteLine("\nzad1 lambda\n");

            var query1cd = marki
                .Join(
                    models,
                    marka => marka.ID,
                    model => model.refMarka,
                    (marka, model) => new { marka.Nazwa, model.name, model.prop }
                );

            foreach (var q2 in query1)
            {
                foreach (var q3 in q2.prop)
                {
                    Console.WriteLine("{0}:{1}:{2}", q2.Nazwa, q3.engineTorque, q3.fuelType);
                }

            }

            Console.WriteLine("\nzad2\n");
            var query2 = from marka in marki
                         join model in models on marka.ID equals model.refMarka
                         orderby marka.Nazwa, model.name
                         select new { marka.Nazwa, model.name, model.prop };

            foreach (var q2 in query2)
            {
                foreach (var q3 in q2.prop)
                {
                    Console.WriteLine("{0}:{1}:{2}:{3}", q2.Nazwa, q2.name, q3.fuelType, q3.enginePower);
                }

            }

            Console.WriteLine("\nzad2 lambda\n");
            var query2cd = marki
                .Join(
                    models,
                    marka => marka.ID,
                    model => model.refMarka,
                    (marka, model) => new { marka.Nazwa, model.name, model.prop }
                )
                .OrderBy(joined => joined.Nazwa)
                .ThenBy(joined => joined.name);

            foreach (var q2 in query2cd)
            {
                foreach (var q3 in q2.prop)
                {
                    Console.WriteLine("{0}:{1}:{2}:{3}", q2.Nazwa, q2.name, q3.fuelType, q3.enginePower);
                }
            }
           
            Console.WriteLine("\nzad3\n");
            var query3 = from marka in marki
                         join model in models on marka.ID equals model.refMarka
                         group model by new { marka.Nazwa } into samGroup
                         select new {samGroup.Key, count =samGroup.Select(
                             model=> model.prop.Where(param=>param.fuelType == "Petrol")).Count()
                        };
            
            foreach (var q2 in query3)
            {
                Console.WriteLine("{0}:{1}", q2.Key.Nazwa, q2.count);
            }

            Console.WriteLine("\nzad3 lambda\n");
            var query3cd = marki
                .Join(
                    models,
                    marka => marka.ID,
                    model => model.refMarka,
                    (marka, model) => new { marka.Nazwa, model}
                )
                .GroupBy(
                    joined => new {joined.Nazwa },
                    joined => joined.model
                )
                .Select(
                    samGroup => new {
                    samGroup.Key,
                    count = samGroup.Select(
                    model => model.prop.Where(p => p.fuelType == "Petrol")).Count()
                    }
            );

            foreach (var q2 in query3cd)
            {
                Console.WriteLine("{0}:{1}", q2.Key.Nazwa, q2.count);
            }
           
            Console.ReadKey();
        }
    }
}

 

