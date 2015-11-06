#! /usr/bin/env ruby
#
require 'rubygems'
require 'bundler/setup'
require 'commander/import'
require 'sequel'


program :name, "Task Trooper"
program :version, '1.0.0'
program :description, 'A simple command-line based task manager'

config_dir = File.expand_path('~/.task-trooper')
unless Dir[config_dir].length > 0
    Dir::mkdir(config_dir)
end

DB = Sequel.sqlite("#{config_dir}/tasks_db.db")

unless DB.table_exists? :tasks
    DB.create_table(:tasks) do
      primary_key :id
      String :project
      String :title
      String :description
      Boolean :completed
    end
end

ds = DB[:tasks]

command :new do |c|
    c.syntax = 'task-trooper new'
    c.description = 'Creates a new task'
    c.option '--title STRING', String, 'Title of the task'
    c.option '--project STRING', String, 'Name of the Project for this task'
    c.option '--description STRING', String, 'Task description'
    c.action do |args, options|
        if options.project.nil?
            options.project = ask('Provide a Project for the task: ')
        end
        if options.title.nil?
            options.title = ask('Provide a title for the task: ')
        end
        if options.description.nil?
            options.description = ask('Provide a description for the task: ')
        end
        ds.insert(:project => options.project, :title => options.title, :description => options.description, :completed => false)
        say 'Task created.!'
    end
end

command :list do |c|
    c.syntax = 'task-trooper list'
    c.description = 'List the tasks'
    c.action do |args, options|
        ds.each do |task|
            status = if task[:completed] then "completed" else "pending" end
            puts "Task [#{task[:id]}] - #{task[:project]} : <#{status}> : #{task[:title]} : #{task[:description]}"
        end
        pending_count = ds.where(:completed => false).count
        count = ds.count
        completed_count = count - pending_count
        puts "\n"
        puts "Out of #{count} Total Tasks : #{pending_count} pending, #{completed_count} completed."
    end
end

command :done do |c|
    c.syntax = 'task-trooper done <id>'
    c.description = 'Mark a task as done'
    c.action do |args, options|
        if args.first.nil?
            puts "Please specify the task to be marked as COMPLETE: "
        else
            items = ds.where(:id => args.first)
            if items.count > 0
                items.update(:completed => true)
                puts "Updated"
            else
                puts "No Item found..!"
            end
        end
    end
end

command :delete do |c|
    c.syntax = 'task-trooper delete <id>'
    c.description = 'Delete a task'
    c.action do |args, options|
        if args.first.nil?
            puts "Please specify the Task-ID to be deleted"
        else
            items = ds.where(:id => args.first)
            if items.count > 0
                items.delete
                puts "Deleted"
            else
                puts "No task found"
            end
        end
    end
end
